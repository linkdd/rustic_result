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
      "Expected an ok result, \"#{inspect(e.reason)}\" given."
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

  @doc "Unwrap an Ok result, or raise an Err result as an exception"
  @spec unwrap!(t()) :: any()
  def unwrap!({:ok, val}), do: val
  def unwrap!({:error, reason}), do: raise UnhandledError, reason: reason

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
end
