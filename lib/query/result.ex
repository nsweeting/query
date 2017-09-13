defmodule Query.Result do
  alias Query.Result
  alias Query.Builder
  alias Query.Result.{Data, Meta}

  defstruct [
    :data,
    :meta
  ]

  def new(%Builder{} = builder) do
    %Result{}
    |> put_data(builder)
    |> put_meta(builder)
  end

  def put_data(%Result{} = result, %Builder{} = builder) do
    %{result | data: Data.new(builder)}
  end

  def put_meta(%Result{data: data} = result,  %Builder{} = builder) do
    %{result | meta: Meta.new(builder, data)}
  end
end
