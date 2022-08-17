#!/usr/bin/env elixir

defmodule Indexer do
  @moduledoc """
  Experimental script that recursively traverses directories (from the current
  one) and generates _INDEX.md files in each in order to create some sort of
  table of contents for each.
  """
  @exclude ~w/.git .obsidian .DS_Store attachments _INDEX.md/

  def run() do
    starting_root = File.cwd!()

    recursive(starting_root)
    generate_index(starting_root)
  end

  defp recursive(dir) do
    Enum.each(File.ls!(dir), fn file ->
      fname = Path.join(dir, file)

      if File.dir?(fname) && !skip?(fname) do
        generate_index(fname)
        recursive(fname)
      end
    end)
  end

  defp skip?(path), do: Enum.any?(@exclude, &String.contains?(path, &1))

  defp generate_index(fname) do
    content = content_for(fname)
    path = Path.join(fname, "_INDEX.md")

    IO.puts("\nGenerating index for #{fname}:\n#{content}")

    File.open(path, [:write, :utf8], fn f ->
      IO.write(f, content)
    end)
  end

  # Example:
  #
  # - [Software Architecture](c-areas/SoftwareArchitecture/_INDEX.md)
  # - [vim](d-resources/vim,%20tmux,%20cli,%20fish/_INDEX.md)
  defp content_for(dir) do
    File.ls!(dir)
    |> Enum.reject(&skip?/1)
    |> Enum.map(fn file ->
      fname = Path.join(dir, file)
      escaped = URI.encode(file)
      name = String.replace(file, ~r/\.md$/, "")

      if File.dir?(fname) do
        "- [#{name}](#{escaped}/_INDEX.md)"
      else
        "- [#{name}](#{escaped})"
      end
    end)
    |> Enum.sort()
    |> Enum.join("\n")
  end
end

Indexer.run()
