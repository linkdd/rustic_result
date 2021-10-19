defmodule Rustic.Result.Test do
  use ExUnit.Case
  doctest Rustic.Result

  import Rustic.Result

  test "is_ok?/1" do
    assert ok(1) |> is_ok?()
    assert not (err(:failed) |> is_ok?())
  end

  test "is_err?/1" do
    assert not (ok(1) |> is_err?())
    assert err(:failed) |> is_err?()
  end

  test "unwrap!/1" do
    assert 42 == ok(42) |> unwrap!()

    assert_raise Rustic.Result.UnhandledError, fn ->
      err(:failed) |> unwrap!()
    end
  end

  test "unwrap_err!/1" do
    assert_raise Rustic.Result.MissingError, fn ->
      ok(42) |> unwrap_err!()
    end

    assert :failed == err(:failed) |> unwrap_err!()
  end

  test "unwrap_or/2" do
    assert 42 == ok(42) |> unwrap_or(43)
    assert 43 == err(:failed) |> unwrap_or(43)
  end

  test "map/2" do
    assert ok(2) == ok(1) |> map(fn v -> v + 1 end)
    assert err(:failed) == err(:failed) |> map(fn v -> v + 1 end)
  end

  test "map_err/2" do
    assert ok(1) == ok(1) |> map_err(fn reason -> {:failed, reason} end)
    assert err({:failed, :not_found}) == err(:not_found) |> map_err(fn reason -> {:failed, reason} end)
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

  test "flatten/1" do
    assert ok(42) == ok(ok(42)) |> flatten()
    assert err(:failed) == ok(err(:failed)) |> flatten()
    assert ok(42) == ok(42) |> flatten()

    assert ok(42) == err(ok(42)) |> flatten()
    assert err(:failed) == err(err(:failed)) |> flatten()
    assert err(:failed) == err(:failed) |> flatten()
  end

  test "collect/1" do
    assert ok([1, 2]) == [ok(1), ok(2)] |> collect()
    assert err(:failed) == [ok(1), err(:failed)] |> collect()
  end

  test "filter_collect/1" do
    assert ok([1, 2]) == [ok(1), ok(2)] |> filter_collect()
    assert ok([1]) == [ok(1), err(:failed)] |> filter_collect()
  end

  test "partition_collect/1" do
    assert {ok([1, 2]), err([])} == [ok(1), ok(2)] |> partition_collect()
    assert {ok([1]), err([:failed])} == [ok(1), err(:failed)] |> partition_collect()
  end
end
