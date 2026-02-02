#!/usr/bin/env -S ERL_FLAGS=+B elixir

Mix.install([{:httpoison, "~> 2.3"}])

defmodule Lights do
  alias Config.Reader

  require Logger

  @selfname Path.basename(__ENV__.file)
  @config Path.expand("~/.local/lights.conf")

  @moduledoc """
  Lights is a utility that switches Elgato lights in Home Assistant on/off when the macOS camera
  powers on/off by watching the system log.

  ## Configuration

  Requires `~/.local/lights.conf` with:

      import Config

      config :lights, ha_base: "http://<your_ha_instance_ip>:8123"
      config :lights, ha_token: "your_token_here"

  Token can be generated at http://<your_ha_instance_ip>:8123/profile/security page.

  ## Log Access

  The `log stream` command requires administrative privileges, we can run with it sudo. To allow
  passwordless execution:

      sudo mkdir -p /private/etc/sudoers.d
      echo "$USER ALL=(ALL) NOPASSWD: /usr/bin/log" | sudo tee /private/etc/sudoers.d/log-$USER
      sudo chmod 440 /private/etc/sudoers.d/log-$USER

  ## Daemon Usage

  Can be used as a macOS LaunchAgent. Copy `lights.plist` file to `~/Library/LaunchAgents/`, adjust
  it (e.g., path to lights.exs in the ProgramArguments), and control via:

      launchctl load ~/Library/LaunchAgents/lights.plist
      launchctl unload ~/Library/LaunchAgents/lights.plist

  Watch for logs in `~/Library/Logs/lights*.log`.

  ## Basic Usage

      $ #{@selfname} --watch
  """

  def main(argv) do
    {parsed, _args} = OptionParser.parse!(argv, strict: [watch: :boolean])

    case parsed do
      [watch: true] ->
        configure_logger()
        load_settings()

        Logger.info("#{@selfname} starts watching...")

        Lights.Application.start(nil, [])

      _ ->
        IO.puts(@moduledoc)
        System.halt(0)
    end
  end

  defp load_settings() do
    settings = Config.Reader.read!(@config)

    for {app, app_config} <- settings, {key, value} <- app_config do
      Application.put_env(app, key, value)
    end
  end

  defp configure_logger() do
    formatter = Logger.default_formatter(format: "$date $time [$level] $message\n")

    :logger.update_handler_config(:default, :formatter, formatter)
  end
end

defmodule Lights.Application do
  use Application

  def start(_type, _args) do
    children = [{Lights.Watchdog, []}]

    Supervisor.start_link(children, strategy: :one_for_one, name: Lights.Supervisor)
  end
end

defmodule Lights.Watchdog do
  @moduledoc """
  In macOS, camera events are logged into the system log. We shall monitor and select the relevant
  ones. The com.apple.cmio subsystem handles built-in FaceTime/iSight cameras, while
  com.apple.UVCExtension handles external USB Video Class cameras.

  We monitor both and filter significant events using the `--predicate` option of the `log` command.

  `scruffy.sh` script is a wrapper to execute long-running processes via Port to avoid leaving
  orphaned zombie processes in case of BEAM abnormal termination.
  """

  use GenServer

  @scruffy Path.expand("~/.dotfiles/littles/scruffy.sh")
  @mac_log ~s[#{@scruffy} sudo log stream --color none --style compact --predicate '(subsystem == "com.apple.UVCExtension" AND composedMessage CONTAINS "Post PowerLog") OR (subsystem == "com.apple.cmio" AND (composedMessage CONTAINS "CMIOGraphStart" OR composedMessage CONTAINS "CMIOGraphStop"))']

  def start_link(_opts),
    do: GenServer.start_link(__MODULE__, nil, name: __MODULE__)

  def init(nil) do
    Process.flag(:trap_exit, true)

    port = Port.open({:spawn, @mac_log}, [:binary, :exit_status])

    {:ok, port}
  end

  def handle_info({_port, {:data, log_line}}, port) do
    cond do
      String.contains?(log_line, "\"VDCAssistant_Power_State\" = On") ->
        Lights.Controller.turn_all(:on)

      String.contains?(log_line, "\"VDCAssistant_Power_State\" = Off") ->
        Lights.Controller.turn_all(:off)

      String.contains?(log_line, "CMIOGraphStart Calling Start()") ->
        Lights.Controller.turn_all(:on)

      String.contains?(log_line, "CMIOGraphStop Calling Stop()") ->
        Lights.Controller.turn_all(:off)

      true ->
        nil
    end

    {:noreply, port}
  end
end

defmodule Lights.Controller do
  require Logger

  def turn_all(action) when action in [:on, :off] do
    list_lamps()
    |> Task.async_stream(fn %{"entity_id" => lamp_id} -> turn_lamp(lamp_id, action) end)
    |> Stream.run()
  end

  defp list_lamps() do
    url = "#{base_url()}/api/states"
    headers = auth_headers()

    case HTTPoison.get(url, headers) do
      {:ok, %{status_code: 200, body: body}} ->
        :json.decode(body) |> Enum.filter(&is_elgato_lamp?/1)

      _ ->
        []
    end
  end

  defp base_url(), do: Application.get_env(:lights, :ha_base)

  defp auth_headers(),
    do: [{"Authorization", "Bearer #{Application.get_env(:lights, :ha_token)}"}]

  defp is_elgato_lamp?(%{"entity_id" => entity_id}),
    do: String.starts_with?(entity_id, "light.elgato_")

  defp turn_lamp(lamp_id, action) when action in [:on, :off] do
    url = "#{base_url()}/api/services/light/turn_#{action}"
    body = :json.encode(%{entity_id: lamp_id})
    headers = auth_headers()

    Logger.info("turning #{lamp_id} #{action}")

    case HTTPoison.post(url, body, headers) do
      {:ok, %{status_code: 200}} -> :ok
      _ -> :error
    end
  end
end

Lights.main(System.argv())

Process.sleep(:infinity)
