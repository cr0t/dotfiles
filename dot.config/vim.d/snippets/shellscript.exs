#!/usr/bin/env -S ERL_FLAGS=+B elixir

Mix.install([])

if System.get_env("DEPS_ONLY") == "true" do
  System.halt(0)
  Process.sleep(:infinity)
end

defmodule Hello do
  @selfname Path.basename(__ENV__.file)

  @moduledoc """
  <!-- TODO -->

  ## Usage

      $ #{@selfname} --help
  """

  @args [help: :boolean]
  def main(args) do
    {parsed, args} = OptionParser.parse!(args, strict: @args)

    cmd(parsed, args)
  end

  defp cmd([help: true], _), do: IO.puts(@moduledoc)

  defp cmd(_parsed, _args) do
    # ...
    System.stop(1)
  end
end

Hello.main(System.argv())
