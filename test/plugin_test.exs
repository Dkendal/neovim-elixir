defmodule NVim.PluginTest do
  use ExUnit.Case
  alias NVim.Plugin
  doctest NVim.Plugin

  test "do_defcommand" do
    arg1 = quote(do: foo(x, y, z))
    arg2 = [bang: true, eval: "xx", count: true, eval: "xx"]

    Plugin.do_defcommand(arg1, arg2, do: nil)
    |> Macro.to_string()
    |> Code.format_string!()
    |> IO.puts()
  end
end
