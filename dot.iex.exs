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
  @tips_n_tricks [
    ":observer.start() - a graphical tool for observing the characteristics of Erlang systems",
    "runtime_info <:memory|:applications|...> - prints VM/runtime information",
    "IEx.configure(inspect: [limit: :infinity]) - shows full values in output without cuts"
  ]

  def print_tips_n_tricks() do
    print_bright("--- Tips & Tricks:")

    @tips_n_tricks
    |> Enum.map(&IO.puts/1)
  end

  def print_bright(text) do
    (IO.ANSI.bright() <>
       text <>
       IO.ANSI.reset())
    |> IO.puts()
  end

  # Get queue length for the IEx process: this is fun to see while playing with nodes
  def queue_length do
    self()
    |> Process.info()
    |> Keyword.get(:message_queue_len)
  end

  def is_app_started?(app) do
    Application.started_applications()
    |> Enum.any?(&(elem(&1, 0) == app))
  end
end

# First time I've learned about custom .iex.exs here
# https://www.youtube.com/watch?v=E0bmtcYrz9M
# Here is a good article:
# https://samuelmullen.com/articles/customizing_elixirs_iex/
# Most of the code below, originally found here:
# https://www.adiiyengar.com/blog/20180709/my-iex-exs

# Will be using `ANSI`
Application.put_env(:elixir, :ansi_enabled, true)

# Letting people know what iex.exs they are using
H.print_tips_n_tricks()

inspect_limit = 5_000
history_size = 100

prefix = IO.ANSI.green() <> "%prefix" <> IO.ANSI.reset()
counter = IO.ANSI.green() <> "-%node-(%counter)" <> IO.ANSI.reset()
info = IO.ANSI.light_blue() <> "✉ #{H.queue_length()}" <> IO.ANSI.reset()
last = IO.ANSI.yellow() <> "➤" <> IO.ANSI.reset()

alive =
  IO.ANSI.bright() <>
    IO.ANSI.yellow() <>
    IO.ANSI.blink_rapid() <>
    "⚡" <>
    IO.ANSI.reset()

default_prompt = prefix <> counter <> " | " <> info <> " | " <> last
alive_prompt = prefix <> counter <> " | " <> info <> " | " <> alive <> last

###
## IEx Settings
###

IEx.configure(
  inspect: [limit: inspect_limit],
  history_size: history_size,
  colors: [
    eval_result: [:green, :bright],
    eval_error: [:red, :bright],
    eval_info: [:blue, :bright]
  ],
  default_prompt: default_prompt,
  alive_prompt: alive_prompt
)

###
## Phoenix & Ecto Helpers
###

H.print_bright("--- Phoenix & Ecto:")

phoenix_started? = H.is_app_started?(:phoenix)
ecto_started? = H.is_app_started?(:ecto)

phoenix_info =
  if phoenix_started? do
    IO.ANSI.green() <> "running" <> IO.ANSI.reset()
  else
    IO.ANSI.yellow() <> "not detected" <> IO.ANSI.reset()
  end

IO.puts("Phoenix app: #{phoenix_info}")

ecto_info =
  if ecto_started? do
    IO.ANSI.green() <> "running" <> IO.ANSI.reset()
  else
    IO.ANSI.yellow() <> "not detected" <> IO.ANSI.reset()
  end

repo_info =
  if ecto_started? do
    repo =
      Mix.Project.get().project()[:app]
      |> Application.get_env(:ecto_repos)
      |> Enum.at(0)

    IO.ANSI.faint() <> "(`alias #{repo}, as: Repo`)" <> IO.ANSI.reset()
  else
    ""
  end

if ecto_started? do
  import_if_available(Ecto.Query)
  import_if_available(Ecto.Changeset)
end

IO.puts("Ecto app: #{ecto_info} #{repo_info}")
