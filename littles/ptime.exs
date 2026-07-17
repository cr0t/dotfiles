#!/usr/bin/env elixir

defmodule PTime do
  @moduledoc """
  A tiny script that gives current week of the year + number of weeks since
  kids' birth date in a format that is being used in their logs. Here it is:

    W40 _(+11)_, 2026-09-29: ...
    ^^^   ^^^       ^^^^^    ^^^
     1     2          3       4

    1 – Week of the year
    2 – Number of weeks from birth
    3 – Date
    4 – Message

  Usage examples:

    ptime.exs polina 2026-07-16
    W29 _(+0)_, 2026-07-16:

    ptime.exs timofey
    W29 _(+184)_, 2026-07-17:

  If you omit the date, the current UTC one will be used.
  """
  def main(argv) do
    [child, date] =
      case argv do
        [c, d] -> [c, Date.from_iso8601!(d)]
        [c] -> [c, Date.utc_today()]
      end

    case child do
      "timofey" -> timofey(date)
      "polina" -> polina(date)
    end
  end

  def timofey(date), do: prefix(date, ~D[2023-01-02])

  def polina(date), do: prefix(date, ~D[2026-07-11])

  defp prefix(date, born) do
    {_year, week_number} = :calendar.iso_week_number(Date.to_erl(date))
    week_diff = floor(Date.diff(date, born) / 7)

    "W#{week_number} _(+#{week_diff})_, #{date}: "
  end
end

System.argv() |> PTime.main() |> IO.puts()
