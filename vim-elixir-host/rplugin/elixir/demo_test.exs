defmodule ExampleTest do
  use ExUnit.Case

  def pipe_out(line) do
    with {:ok, ast} <- Code.string_to_quoted(line),
         {fun, _, [hd | tail]} <- ast do
      ast = {:|>, [], [hd, {fun, [], tail}]}
      lpad = String.duplicate(" ", count_left_just(line))
      out = lpad <> Macro.to_string(ast)
      {:ok, out}
    end
  end

  def pipe_in(line) do
    with {:ok, ast} <- Code.string_to_quoted(line),
         {:|>, _, [hd, {fun, _, tail}]} <- ast do
      ast = {fun, [], [hd | tail]}
      lpad = String.duplicate(" ", count_left_just(line))
      out = lpad <> Macro.to_string(ast)
      {:ok, out}
    end
  end

  def count_left_just(string, count \\ 0)
  def count_left_just("", count), do: count
  def count_left_just(" " <> rest, count), do: count_left_just(rest, count + 1)
  def count_left_just(_, count), do: count

  test "pipe_out" do
    assert pipe_out("X.Y.foo(1)") == {:ok, "1 |> X.Y.foo()"}
    assert pipe_out("foo(1, 2)") == {:ok, "1 |> foo(2)"}
    assert pipe_out("foo(bar(x))") == {:ok, "bar(x) |> foo()"}
    assert pipe_out("foo(bar(x), y)") == {:ok, "bar(x) |> foo(y)"}
    assert pipe_out("  foo(1)") == {:ok, "  1 |> foo()"}
  end

  test "pipe_in" do
    foo(1)
    assert pipe_in("1 |> X.Y.foo()") == {:ok, "X.Y.foo(1)"}
    assert pipe_in("1 |> foo(2)") == {:ok, "foo(1, 2)"}
    assert pipe_in("bar(x) |> foo()") == {:ok, "foo(bar(x))"}
    assert pipe_in("bar(x) |> foo(y)") == {:ok, "foo(bar(x), y)"}
    assert pipe_in("  1 |> foo()") == {:ok, "  foo(1)"}
  end
end
