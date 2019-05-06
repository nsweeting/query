defmodule Query.Result do
  @moduledoc false

  alias Query.Result
  alias Query.Result.{Data, Meta}

  defstruct [
    :data,
    :meta
  ]

  @type t :: %__MODULE__{
          data: list() | nil,
          meta: Query.Result.Meta.t() | nil
        }

  @spec new(Query.t()) :: Query.Result.t()
  def new(query) do
    %Result{}
    |> put_data(query)
    |> put_meta(query)
  end

  @spec put_data(Query.Result.t(), Query.t()) :: Query.Result.t()
  def put_data(result, query) do
    %{result | data: Data.new(query)}
  end

  @spec put_meta(Query.Result.t(), Query.t()) :: Query.Result.t()
  def put_meta(result, query) do
    %{result | meta: Meta.new(query, result.data)}
  end
end
