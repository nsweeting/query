defmodule Query.Builder do
  @moduledoc """
  The Query.Builder takes our user-provided params, as well as our options,
  """

  alias Query.Config
  alias Query.Builder
  alias Query.Builder.{Page, Scope, Sort}

  defstruct page: nil,
            limit: nil,
            offset: nil,
            sorting: nil,
            scopes: nil,
            repo: nil,
            queryable: nil

  @type param :: %{binary => binary}
  @type t :: %__MODULE__{}

  @spec new(queryable :: Ecto.Queryable.t(), param, list) :: Query.Builder.t() | no_return()
  def new(_, params \\ %{}, options \\ [])

  def new(queryable, params, options)
      when is_atom(queryable) and is_map(params) and is_list(options) do
    queryable
    |> Ecto.Queryable.to_query()
    |> new(params, options)
  end

  def new(queryable, params, options)
      when is_map(params) and is_list(options) do
    options = Config.options(:builder, options)

    repo = Keyword.get(options, :repo)
    paging = Keyword.get(options, :paging)
    sorting = Keyword.get(options, :sorting)
    scopes = Keyword.get(options, :scopes)

    %Builder{}
    |> put_queryable(queryable)
    |> put_repo(repo)
    |> put_paging(params, paging)
    |> put_sorting(params, sorting)
    |> put_scopes(params, scopes)
  end

  @spec put_queryable(builder :: Query.Builder.t(), Ecto.Queryable.t()) :: Query.Builder.t()
  def put_queryable(builder, queryable) do
    %{builder | queryable: queryable}
  end

  @spec put_repo(builder :: Query.Builder.t(), atom) :: Query.Builder.t()
  def put_repo(builder, repo) do
    %{builder | repo: repo}
  end

  @spec put_paging(builder :: Query.Builder.t(), param, list) :: Query.Builder.t()
  def put_paging(builder, params, paging) do
    {limit, offset, page} = Page.new(params, paging)
    %{builder | limit: limit, offset: offset, page: page}
  end

  @spec put_sorting(builder :: Query.Builder.t(), param, list) :: Query.Builder.t()
  def put_sorting(builder, params, sorting) do
    sorting = Sort.new(params, sorting)
    %{builder | sorting: sorting}
  end

  @spec put_scopes(builder :: Query.Builder.t(), param, list) :: Query.Builder.t()
  def put_scopes(builder, params, scopes) do
    scopes = Scope.new(params, scopes)
    %{builder | scopes: scopes}
  end
end
