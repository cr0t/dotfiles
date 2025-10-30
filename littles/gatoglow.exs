#!/usr/bin/env -S ERL_FLAGS=+B elixir

Mix.install([{:httpoison, "~> 2.2.1"}])

defmodule GatoGlow do
  require Logger

  @selfname Path.basename(__ENV__.file)

  @moduledoc """
  GatoGlow is a tiny utility that switches on and off configured Elgato lights correspondingly to
  macOS camera power on and off events. The utility watches the system log for that.

  ## Daemon...

  It can (and should) be used as macOS agent (a daemon utility that works in the background). To
  make it work like that, we need to copy the `gatoglow.plist` (lies next to this file) into
  `~/Library/LaunchAgents/` folder, and then control it via these commands:

      launchctl load ~/Library/LaunchAgents/gatoglow.plist
      # or
      launchctl unload ~/Library/LaunchAgents/gatoglow.plist

  See logs in the `~/Library/Logs/gatoglow*.log` files.

  ## Basic Usage

      $ #{@selfname} --watch
  """

  @args [watch: :boolean]

  def main(args) do
    configure_logger()

    {parsed, args} = OptionParser.parse!(args, strict: @args)

    cmd(parsed, args)
  end

  defp cmd([watch: true], _) do
    Logger.info("#{@selfname} is starting to watch...")

    GatoGlow.Application.start(nil, [])
  end

  defp cmd(_parsed, _args) do
    IO.puts(@moduledoc)

    System.halt(0)
  end

  defp configure_logger() do
    formatter = Logger.default_formatter(format: "$date $time [$level] $message\n")

    :logger.update_handler_config(:default, :formatter, formatter)
  end
end

defmodule GatoGlow.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [{GatoGlow.LogListener, []}]

    Supervisor.start_link(children, strategy: :one_for_one, name: GatoGlow.Supervisor)
  end
end

defmodule GatoGlow.LogListener do
  @moduledoc """
  """

  use GenServer

  @camera_events ~s[/Users/cr0t/.dotfiles/littles/scruffy.sh log stream --color none --style compact --predicate 'subsystem == "com.apple.UVCExtension" AND composedMessage CONTAINS "Post PowerLog"']

  @elgato_devices %{
    "elgato-ring-light-1d0f.local" => %{
      name: "Ring Light",
      brightness: 70,
      temperature: 4250,
      # 2950-7000 (precisely, 2903-7017)
      temp_range: 143..344
    },
    "elgato-key-light-air-eb9e.local" => %{
      name: "Key Light Air #2",
      brightness: 70,
      temperature: 4250,
      # but we don't know for real: it allows any values from 40 to 10000...
      temp_range: 143..344
    },
    "elgato-light-strip-82da.local" => %{
      name: "Light Strip",
      brightness: 70,
      temperature: 4250,
      # 3550-6550 (precisely, 3503–6557)
      temp_range: 153..285
    }
  }

  def start_link(opts \\ []),
    do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)

  def init(_opts) do
    Process.flag(:trap_exit, true)

    port = Port.open({:spawn, @camera_events}, [:binary, :exit_status])

    {:ok, port}
  end

  def handle_info({_port, {:data, data}}, port) do
    cond do
      String.contains?(data, "\"VDCAssistant_Power_State\" = On") -> all_on()
      String.contains?(data, "\"VDCAssistant_Power_State\" = Off") -> all_off()
      true -> nil
    end

    {:noreply, port}
  end

  def handle_info(msg, port) do
    Logger.warning("Unexpected message for LogListener: #{inspect(msg)}")

    {:noreply, port}
  end

  defp all_on() do
    Enum.each(@elgato_devices, fn {ip, settings} ->
      Task.start(fn ->
        GatoGlow.ElgatoController.on(
          {ip, settings[:name]},
          settings[:temperature],
          settings[:brightness],
          settings[:temp_range]
        )
      end)
    end)
  end

  defp all_off() do
    Enum.each(@elgato_devices, fn {ip, %{name: name}} ->
      Task.start(fn ->
        GatoGlow.ElgatoController.off({ip, name})
      end)
    end)
  end
end

defmodule GatoGlow.ElgatoController do
  @moduledoc false

  require Logger

  def on({ip, name}, temperature_in_kelvin, brightness, allowed_range) do
    temperature = kelvin_to_mired(temperature_in_kelvin, allowed_range)

    payload = %{
      numberOfLights: 1,
      lights: [%{brightness: brightness, on: 1, temperature: temperature}]
    }

    try do
      HTTPoison.put!("http://#{ip}:9123/elgato/lights", :json.encode(payload))

      Logger.info("Switched on #{ip} - #{name}")
    rescue
      _ -> Logger.info("Unable to switch on #{ip} - #{name}")
    end
  end

  def off({ip, name}) do
    payload = %{
      numberOfLights: 1,
      lights: [%{on: 0}]
    }

    try do
      HTTPoison.put!("http://#{ip}:9123/elgato/lights", :json.encode(payload))

      Logger.info("Switched off #{ip} - #{name}")
    rescue
      _ -> Logger.info("Unable to switch off #{ip} - #{name}")
    end
  end

  @doc """
  Elgato lights API use integers in the range of 143-344 to control the color temperature. The
  range they usually allow to set temperature is in 2900-7000K. Very likely, they use the mired
  formula to convert it to integer.

  Read more about conversion: https://en.wikipedia.org/wiki/Mired
  """
  def kelvin_to_mired(kelvin_degrees, allowed_range) do
    mired = round(1_000_000 / kelvin_degrees)

    max = Enum.max(allowed_range)
    min = Enum.min(allowed_range)

    # we do extra check for edge values, just to avoid rounding issues
    cond do
      mired > max -> max
      mired < min -> min
      true -> mired
    end
  end
end

########################################################################

GatoGlow.main(System.argv())

Process.sleep(:infinity)
