defmodule Query.Result do
  @type t :: %__MODULE__{
    data:       list,
    meta:       map
  }

  alias Query.Result
  alias Query.Builder
  alias Query.Result.{Data, Meta}

  defstruct [
    :data,
    :meta
  ]

  @spec new(Query.Builder.t) :: Query.Result.t
  def new(%Builder{} = builder) do
    %Result{}
    |> put_data(builder)
    |> put_meta(builder)
  end

  @spec put_data(Query.Result.t, Query.Builder.t ) :: Query.Result.t
  def put_data(%Result{} = result, %Builder{} = builder) do
    %{result | data: Data.new(builder)}
  end

  @spec put_meta(Query.Result.t, Query.Builder.t ) :: Query.Result.t
  def put_meta(%Result{data: data} = result,  %Builder{} = builder) do
    %{result | meta: Meta.new(builder, data)}
  end
end
