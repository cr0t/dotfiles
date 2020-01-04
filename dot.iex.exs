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

# First time I've learned about custom .iex.exs here
# https://www.youtube.com/watch?v=E0bmtcYrz9M
# Here is a good article:
# https://samuelmullen.com/articles/customizing_elixirs_iex/
# Most of the code below, originally found here:
# https://www.adiiyengar.com/blog/20180709/my-iex-exs

print_bright = fn text ->
  (IO.ANSI.bright() <>
     text <>
     IO.ANSI.reset())
  |> IO.puts()
end

# Get queue length for the IEx process: this is fun to see while playing with nodes
queue_length = fn ->
  self()
  |> Process.info()
  |> Keyword.get(:message_queue_len)
end

# Will be using `ANSI`
Application.put_env(:elixir, :ansi_enabled, true)

# Letting people know what iex.exs they are using
print_bright.("Using global .iex.exs (located in ~/.iex.exs)")

inspect_limit = 5_000
history_size = 100

prefix = IO.ANSI.green() <> "%prefix" <> IO.ANSI.reset()
counter = IO.ANSI.green() <> "-%node-(%counter)" <> IO.ANSI.reset()
info = IO.ANSI.light_blue() <> "✉ #{queue_length.()}" <> IO.ANSI.reset()
last = IO.ANSI.yellow() <> "➤" <> IO.ANSI.reset()

alive =
  IO.ANSI.bright() <>
    IO.ANSI.yellow() <>
    IO.ANSI.blink_rapid() <>
    "⚡" <>
    IO.ANSI.reset()

default_prompt = prefix <> counter <> " | " <> info <> " | " <> last
alive_prompt = prefix <> counter <> " | " <> info <> " | " <> alive <> last

eval_result = [:green, :bright]
eval_error = [:red, :bright]
eval_info = [:blue, :bright]

# Configuring IEx
IEx.configure(
  inspect: [limit: inspect_limit],
  history_size: history_size,
  colors: [
    eval_result: eval_result,
    eval_error: eval_error,
    eval_info: eval_info
  ],
  default_prompt: default_prompt,
  alive_prompt: alive_prompt
)

# Phoenix Support
import_if_available(Plug.Conn)
import_if_available(Phoenix.HTML)

phoenix_app =
  :application.info()
  |> Keyword.get(:running)
  |> Enum.reject(fn {_x, y} ->
    y == :undefined
  end)
  |> Enum.find(fn {x, _y} ->
    x |> Atom.to_string() |> String.match?(~r{_web})
  end)

# Check if Phoenix app is found
case phoenix_app do
  nil ->
    print_bright.("No Phoenix app found")

  {app, _pid} ->
    print_bright.("Phoenix app found: #{app}")

    ecto_app =
      app
      |> Atom.to_string()
      |> (&Regex.split(~r{_web}, &1)).()
      |> Enum.at(0)
      |> String.to_atom()

    ecto_exists =
      :application.info()
      |> Keyword.get(:running)
      |> Enum.reject(fn {_x, y} ->
        y == :undefined
      end)
      |> Enum.map(fn {x, _y} -> x end)
      |> Enum.member?(ecto_app)

    # Check if Ecto app exists or running
    case ecto_exists do
      false ->
        print_bright.("Ecto app #{ecto_app} doesn't exist or isn't running")

      true ->
        print_bright.("Ecto app found: #{ecto_app}")

        # Ecto Support
        import_if_available(Ecto.Query)
        import_if_available(Ecto.Changeset)

        # Alias Repo
        repo = ecto_app |> Application.get_env(:ecto_repos) |> Enum.at(0)

        quote do
          alias unquote(repo), as: Repo
        end
    end
end
