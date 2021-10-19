defmodule Rustic.Result do
  @moduledoc """
  Documentation for `RusticResult`.
  """

  defmodule UnhandledError do
    @moduledoc "Error raised when trying to unwrap an Err result"

    defexception [:reason]

    @doc "Convert error to string"
    @spec message(%__MODULE__{}) :: String.t()
    def message(e) do
      "Expected an Ok result, \"#{inspect(e.reason)}\" given."
    end
  end

  defmodule MissingError do
    @moduledoc "Error raised when trying to unwrap an Ok value"

    defexception [:value]

    @doc "Convert error to string"
    @spec message(%__MODULE__{}) :: String.t()
    def message(e) do
      "Expected an Err result, \"#{inspect(e.value)}\" given."
    end
  end

  @typedoc "Describe an Ok value"
  @type ok :: {:ok, any()}

  @typedoc "Describe an Err value"
  @type err :: {:error, term()}

  @typedoc "Describe a Result type"
  @type t :: ok | err

  @typedoc "A function that maps a value to a result"
  @type f :: (any() -> t())

  @doc "Wraps a value into an Ok result"
  @spec ok(any()) :: ok()
  def ok(v), do: {:ok, v}

  @doc "Wraps a value into an Err result"
  @spec err(term()) :: err()
  def err(reason), do: {:error, reason}

  @doc "Returns true if the Result is an Ok value"
  @spec is_ok?(t()) :: boolean()
  def is_ok?({:ok, _}), do: true
  def is_ok?({:error, _}), do: false

  @doc "Returns true if the Result is an Err value"
  @spec is_err?(t()) :: boolean()
  def is_err?({:ok, _}), do: false
  def is_err?({:error, _}), do: true

  @doc "Unwrap an Ok result, or raise an exception"
  @spec unwrap!(t()) :: any()
  def unwrap!({:ok, val}), do: val
  def unwrap!({:error, reason}), do: raise UnhandledError, reason: reason

  @doc "Unwrap an Err result, or raise an exception"
  @spec unwrap_err!(t()) :: term()
  def unwrap_err!({:ok, val}), do: raise MissingError, value: val
  def unwrap_err!({:error, reason}), do: reason

  @doc "Unwrap an Ok result, or return a default value"
  @spec unwrap_or(t(), any()) :: any()
  def unwrap_or({:ok, val}, _default), do: val
  def unwrap_or({:error, _reason}, default), do: default

  @doc """
  Apply a function to the value contained in an Ok result, or propagates the
  error.
  """
  @spec map(t(), (any() -> any())) :: t()
  def map({:ok, val}, func), do: {:ok, func.(val)}
  def map(err, _func), do: err

  @doc """
  Apply a function to the value contained in an Err result, or propagates the
  Ok result.
  """
  @spec map_err(t(), (any() -> any())) :: t()
  def map_err({:ok, val}, _func), do: {:ok, val}
  def map_err({:error, reason}, func), do: {:error, func.(reason)}

  @doc """
  Apply a function which returns a result to an Ok result, or propagates the
  error.
  """
  @spec and_then(t(), f()) :: t()
  def and_then({:ok, val}, func), do: func.(val)
  def and_then(err, _func), do: err

  @doc """
  Apply a function which returns a result to an Err result, or propagates the
  Ok value.
  """
  @spec or_else(t(), f()) :: t()
  def or_else({:error, reason}, func), do: func.(reason)
  def or_else(ok, _func), do: ok

  @doc """
  Flatten a result containing another result.
  """
  @spec flatten(t()) :: t()
  def flatten({:ok, {:ok, val}}), do: {:ok, val}
  def flatten({:ok, {:error, reason}}), do: {:error, reason}
  def flatten({:ok, val}), do: {:ok, val}
  def flatten({:error, {:ok, val}}), do: {:ok, val}
  def flatten({:error, {:error, reason}}), do: {:error, reason}
  def flatten({:error, reason}), do: {:error, reason}

  @doc """
  Iterate over Results, will fail at the first Error result.
  """
  @spec collect(Enumerable.t(t())) :: t()
  def collect(enumerable) do
    enumerable |> Enum.map(&unwrap!/1) |> ok()
  rescue
    err in UnhandledError ->
      err(err.reason)
  end

  @doc """
  Iterate over Results, will ignore failed items.
  """
  @spec filter_collect(Enumerable.t(t())) :: ok()
  def filter_collect(enumerable) do
    enumerable |> Enum.filter(&is_ok?/1) |> collect()
  end

  @doc """
  Iterate over Results, returns a tuple of:
   - Ok result containing the list of Ok values
   - Err result containing the list of Err reasons
  """
  @spec partition_collect(Enumerable.t(t())) :: {ok(), err()}
  def partition_collect(enumerable) do
    {
      enumerable |> filter_collect(),
      enumerable |> Enum.filter(&is_err?/1) |> Enum.map(&unwrap_err!/1) |> err()
    }
  end
end
