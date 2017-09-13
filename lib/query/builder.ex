defmodule Query.Builder do
  @type t :: %__MODULE__{}

  alias Query.Config

  @defaults [
    paging: Config.get(:paging, %{}),
    sorting: Config.get(:sorting, %{}),
    repo: Config.get(:repo),
    scopes: []
  ]

  defstruct [
    :page,
    :limit,
    :offset,
    :sorting,
    :scopes,
    :repo,
    :queryable
  ]

  @spec new(atom | Ecto.Queryable.t, map, list) :: Query.Builder.t
  def new(_, params \\ %{}, options \\ [])
  def new(atom, params, options)
  when is_atom(atom) and is_map(params) and is_list(options) do
    atom
    |> Ecto.Queryable.to_query()
    |> new(params, options)
  end
  def new(queryable, params, options)
  when is_map(params) and is_list(options) do
    options = Keyword.merge(@defaults, options)
    repo    = Keyword.get(options, :repo)
    paging  = Keyword.get(options, :paging)
    sorting = Keyword.get(options, :sorting)
    scopes  = Keyword.get(options, :scopes)

    %Query.Builder{}
    |> put_queryable(queryable)
    |> put_repo(repo)
    |> put_paging(params, paging)
    |> put_sorting(params, sorting)
    |> put_scopes(params, scopes)
  end

  def put_queryable(options, queryable) do
    %{options | queryable: queryable}
  end

  def put_repo(options, repo) do
    %{options | repo: repo}
  end

  def put_paging(options, params, paging) do
    {limit, offset, page} = Query.Builder.Page.new(params, paging)
    %{options | limit: limit, offset: offset, page: page}
  end

  def put_sorting(options, params, sorting) do
    sorting = Query.Builder.Sort.new(params, sorting)
    %{options | sorting: sorting}
  end

  def put_scopes(options, params, scopes) do
    scopes = Query.Builder.Scope.new(params, scopes)
    %{options | scopes: scopes}
  end
end
