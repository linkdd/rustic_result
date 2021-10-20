# Rustic Result

[![CICD](https://github.com/linkdd/rustic_result/actions/workflows/test-suite.yml/badge.svg)](https://github.com/linkdd/rustic_result)
[![Hex.pm](http://img.shields.io/hexpm/v/rustic_result.svg?style=flat)](https://hex.pm/packages/rustic_result)
[![License](https://img.shields.io/hexpm/l/rustic_result)](https://github.com/linkdd/rustic_result/blob/main/LICENSE.txt)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/rustic_result/)

Result monad for Elixir inspired by Rust
[Result](https://doc.rust-lang.org/std/result/) type.

## Installation

This package can be installed by adding `rustic_result` to your list of
dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:rustic_result, "~> 0.5.0"}
  ]
end
```

## Usage

**NB:** `:ok` is treated as `{:ok, nil}`

```elixir
import Rustic.Result

ok(42) == {:ok, 42}
# true

err(:not_found) == {:error, :not_found}
# true

:ok |> is_ok?()
# true

ok(42) |> is_ok?()
# true

err(:not_found) |> is_err?()
# true

ok(1) |> map(fn v -> v + 1 end)
# ok(2)

:ok |> map(fn nil -> 1 end)
# ok(1)

err(:not_found) |> map(fn v -> v + 1 end)
# err(:not_found)

ok(1) |> map_err(fn reason -> {:failed, reason} end)
# ok(1)

err(:not_found) |> map_err(fn reason -> {:failed, reason} end)
# err({:failed, :not_found})

ok(1) |> and_then(fn v -> ok(v + 1) end)
# ok(2)

:ok |> and_then(fn nil -> ok(1) end)
# ok(1)

ok(1) |> and_then(fn _ -> err(:not_found) end)
# err(:not_found)

err(:not_found) |> and_then(fn v -> ok(v + 1) end)
# err(:not_found)

ok(1) |> or_else(fn _ -> ok(2) end)
# ok(1)

err(:not_found) |> or_else(fn :not_found -> ok(1) end)
# ok(1)

err(:not_found) |> or_else(fn :not_found -> err(:invalid) end)
# err(:invalid)

ok(1) |> unwrap!()
# 1

:ok |> unwrap!()
# nil

err(:not_found) |> unwrap!()
# ** (Rustic.Result.UnhandledError) Expected an Ok result, ":not_found" given.

ok(1) |> unwrap_or(2)
# 1

:ok |> unwrap_or(1)
# nil

err(:not_found) |> unwrap_or(2)
# 2

ok(1) |> unwrap_err!()
# ** (Rustic.Result.MissingError) Expected an Err result, "1" given.

err(:not_found) |> unwrap_err!()
# :not_found

ok(ok(1)) |> flatten()
# ok(1)

ok(err(:failed)) |> flatten()
# err(:failed)

ok(1) |> flatten()
# ok(1)

[ok(1), ok(2)] |> collect()
# ok([1, 2])

[ok(1), err(:not_found)] |> collect()
# err(:not_found)

[ok(1), err(:not_found)] |> filter_collect()
# ok([1])

[ok(1), err(:not_found)] |> partition_collect()
# {ok([1]), err([:not_found])}
```

With function guards:

```elixir
import Rustic.Result

def handle_result(val) when is_ok_result(val) do
  # ...
end
def handle_result(val) when is_err_result(val) do
  # ...
end
def handle_result(val) do
  raise ArgumentError, message: "#{inspect(val)} is not a result"
end
```
