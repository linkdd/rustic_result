defmodule Rustic.Result.Test do
  use ExUnit.Case
  doctest Rustic.Result

  import Rustic.Result

  test "unwrap!/1" do
    assert 42 == ok(42) |> unwrap!()

    assert_raise Rustic.Result.UnhandledError, fn ->
      err(:failed) |> unwrap!()
    end
  end

  test "and_then/2" do
    assert ok(42) == ok(41) |> and_then(fn v -> ok(v + 1) end)
    assert err(41) == ok(41) |> and_then(fn v -> err(v) end)
    assert err(:failed) == err(:failed) |> and_then(fn v -> ok(v + 1) end)
  end

  test "or_else/2" do
    assert ok(41) == ok(41) |> or_else(fn _ -> ok(42) end)
    assert ok(42) == err(:failed) |> or_else(fn :failed -> ok(42) end)
    assert err(:failed) == err(:oops) |> or_else(fn :oops -> err(:failed) end)
  end
end
