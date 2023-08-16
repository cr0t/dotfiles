# Do not forget that you can (and should) use .iex.exs files per each project
# to simplify your life. You can write something like this:
#
# File.exists?(Path.expand("~/.iex.exs")) && import_file("~/.iex.exs")
#
# alias Project.{Repo, User, Post}
#
# defmodule MyHelpers
# # ...
# end

defmodule H do
  @moduledoc """
  Defines a few helper methods to enchance visual appearance and available
  functionality of the IEx.

  ### Extra Information

  First time I've learned about customizations to `.iex.exs` here:
  - https://www.youtube.com/watch?v=E0bmtcYrz9M

  Here is a couple of good articles:
  - https://samuelmullen.com/articles/customizing_elixirs_iex/
  - https://www.adiiyengar.com/blog/20180709/my-iex-exs
  """

  @tips_and_tricks [
    ":observer.start() - a GUI for BEAM",
    "runtime_info <:memory|:applications|...> - sometimes useful data",
    "IEx.configure(inspect: [limit: :infinity]) - show everything"
  ]

  # Lookup an app in the started applications list
  def is_app_started?(app) when is_atom(app) do
    Application.started_applications()
    |> Enum.any?(&(elem(&1, 0) == app))
  end

  # Message queue length for the IEx process: nice to see when playing with
  # remote nodes (distributed Erlang)
  def queue_length do
    self()
    |> Process.info()
    |> Keyword.get(:message_queue_len)
  end

  # Wrap given text in the given ANSI color to prepare for output
  def colorize(text, ansi_color),
    do: ansi_color <> text <> IO.ANSI.reset()

  def print_tips_n_tricks() do
    "\n--- Tips & Tricks:" |> colorize(IO.ANSI.bright) |> IO.puts()

    Enum.map(@tips_and_tricks, &IO.puts/1)
  end
end

# We will be using `ANSI`
Application.put_env(:elixir, :ansi_enabled, true)

# Letting user know some hints
H.print_tips_n_tricks()

###
## IEx Settings
###

prefix = H.colorize("%prefix", IO.ANSI.green)
counter = H.colorize("-%node-(%counter)", IO.ANSI.green)
info = H.colorize("#{H.queue_length()}", IO.ANSI.light_blue)
last = H.colorize(">", IO.ANSI.yellow)
alive = H.colorize("⚡", IO.ANSI.bright <> IO.ANSI.yellow)

default_prompt = prefix <> counter <> " " <> info <> " " <> last
alive_prompt = prefix <> counter <> " " <> info <> " " <> alive <> last

IEx.configure(
  default_prompt: default_prompt,
  alive_prompt: alive_prompt,
  inspect: [limit: 5_000, pretty: true],
  history_size: 100,
  colors: [
    eval_result: [:green, :bright],
    eval_error: [:red, :bright],
    eval_info: [:blue, :bright]
  ]
)

###
## Phoenix & Ecto Helpers
###

"\n--- Phoenix & Ecto:" |> H.colorize(IO.ANSI.bright) |> IO.puts()

phoenix_started? = H.is_app_started?(:phoenix)
ecto_started? = H.is_app_started?(:ecto)

phoenix_info =
  if phoenix_started? do
    H.colorize("running", IO.ANSI.green)
  else
    H.colorize("not detected", IO.ANSI.yellow)
  end

IO.puts("Phoenix: #{phoenix_info}")

ecto_info =
  if ecto_started? do
    H.colorize("running", IO.ANSI.green)
  else
    H.colorize("not detected", IO.ANSI.yellow)
  end

repo_module_name =
  if ecto_started? do
    Mix.Project.get().project()[:app]
    |> Application.get_env(:ecto_repos)
    |> then(fn
      nil ->
        ""

      [repo_mod | _] ->
        repo_alias = Atom.to_string(repo_mod) |> String.replace(~r/^Elixir\./, "")

        H.colorize("(`alias #{repo_alias}, as: Repo`)", IO.ANSI.faint)
    end)
  else
    ""
  end

if ecto_started? do
  import_if_available(Ecto.Query)
  import_if_available(Ecto.Changeset)
end

IO.puts("Ecto: #{ecto_info} #{repo_module_name}")

# One extra empty line before command line
IO.puts("")
