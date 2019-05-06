defmodule Query do
  @moduledoc """
  Query aids the use of Ecto in web settings.

  With it, we can add paging, sorting, and scoping with ease. At its heart, Query
  lets us build complex queries from our controller params.

  ## Example

  Functionality is conducted through one main function `Query.run/4`:

      defmodule App.PostController do
        use App, :controller

        @options [
          sort_permitted: ["id", "title", "inserted_at"],
          scope_permitted: ["by_title"],
          scope: {App.Context, :query}
        ]

        def index(conn, params) do
          result = Query.run(Post, Repo, params, @options)
          render(conn, "index.json", posts: result)
        end
      end

  Given the controller above, we can now pass the following query options.

  `/posts?sort_by=inserted_at&direction=desc&by_title=test`

  Further documentation to come...
  """

  defstruct [
    :page,
    :limit,
    :offset,
    :sorting,
    :scoping,
    :count,
    :count_limit,
    :count_column,
    :repo,
    :queryable
  ]

  alias Query.{Paging, Result, Scoping, Sorting}

  @type t :: %__MODULE__{}
  @type params :: %{binary => binary}
  @type option ::
          {:page_default, non_neg_integer()}
          | {:page_param, binary()}
          | {:limit_default, non_neg_integer()}
          | {:limit_max, non_neg_integer()}
          | {:limit_param, binary()}
          | {:sort_default, binary()}
          | {:sort_param, binary()}
          | {:sort_permitted, [binary()]}
          | {:dir_default, binary()}
          | {:dir_param, binary()}
          | {:count, boolean()}
          | {:count_limit, :infinite | non_neg_integer()}
          | {:scoping, {module(), atom()}}
          | {:scopes, [{module(), binary()}]}
  @type options :: [option()]

  @app_config Application.get_all_env(:query)
  @opts_schema %{
    page_default: [default: 1, type: :integer],
    page_param: [default: "page", type: :binary],
    limit_default: [default: 20, type: :integer],
    limit_max: [default: 50, type: :integer],
    limit_param: [default: "limit", type: :binary],
    sort_default: [default: "id", type: :binary],
    sort_param: [default: "sort_by", type: :binary],
    sort_permitted: [default: [], type: {:list, :binary}],
    dir_default: [default: "asc", type: :binary],
    dir_param: [default: "dir", type: :binary],
    count: [default: true, type: :boolean],
    count_limit: [default: :infinite, type: [:atom, :integer]],
    count_column: [default: :id, type: :atom],
    scope: [required: false, type: [{:tuple, {:atom, :atom}}]],
    scope_permitted: [default: [], type: {:list, :binary}]
  }

  @doc """
  Fetches data from the given repository based on the params and options given.

  This provides an easy way to performing paging, sorting, and scoping all from
  binary maps - typically given from controller params.

  ## Options
    * `:page_default` - the default page if none is provided - defaults to 1
    * `:page_param` - the param key to use for the page - defaults to "page"
    * `:limit_default` - the default limit if none is provided - defaults to 20
    * `:limit_param` - the param key to use for the limit - defaults to "limit"
    * `:limit_max` - the maximum allowed limit - defaults to 50
    * `:sort_default` - the default sort attribute if none is provided - defaults to "id"
    * `:sort_param` - the param key to use for the sort - defaults to "sort_by"
    * `:sort_permitted` - a list of permitted attributes that we can sort on
    * `:dir_default` - the default direction - defaults to "asc"
    * `:dir_param` - the param key to use for the direction - defaults to "dir"
    * `:count` - whether or not to fetch the total number of records - defaults to `true`
    * `:count_limit` - the maximum number of records to count - defaults to  `:infinite`
    * `:count_column` - the column used to perform the count on
    * `:scope_permitted` - a list of permitted params that we can scope on
    * `:scope` - a `{module, function}` with an arity of 2, that will be passed an
      `Ecto.Query` as well as a map of the permitted scopes. You can then perform
      custom queries with these params

  ## Examples

      iex> Query.run(App.Post, App.Repo)
      %Query.Result{data: ...results of query, meta: ...paging attributes}

      iex> Query.run(App.Post, App.Repo, %{"page" => 2, "sort_by" => "some_attr"}, sort_permitted: ["some_attr"])
      %Query.Result{data: ...results of query, meta: ...paging attributes}

      iex> Query.run(App.Post, App.Repo, %{"published" => true}, scope: {App.Context, :with_scope}, scope_permitted: ["published"])
      %Query.Result{data: ...results of query, meta: ...paging attributes}
  """
  @spec run(Ecto.Queryable.t(), Ecto.Repo.t(), params(), options()) :: Query.Result.t()
  def run(_, _, params \\ %{}, opts \\ [])

  def run(queryable, repo, params, opts)
      when is_atom(queryable) and is_atom(repo) and is_map(params) and is_list(opts) do
    queryable
    |> Ecto.Queryable.to_query()
    |> run(repo, params, opts)
  end

  def run(queryable, repo, params, opts)
      when is_atom(repo) and is_map(params) and is_list(opts) do
    config = build_config(opts)

    %Query{}
    |> put_queryable(queryable)
    |> put_repo(repo)
    |> put_counting(config)
    |> put_paging(params, config)
    |> put_sorting(params, config)
    |> put_scoping(params, config)
    |> Result.new()
  end

  defp build_config(opts) do
    @app_config
    |> Keyword.merge(opts)
    |> KeywordValidator.validate!(@opts_schema)
    |> Enum.into(%{})
  end

  defp put_queryable(query, queryable) do
    %{query | queryable: queryable}
  end

  defp put_repo(query, repo) do
    %{query | repo: repo}
  end

  defp put_counting(query, config) do
    %{
      query
      | count: config.count,
        count_limit: config.count_limit,
        count_column: config.count_column
    }
  end

  defp put_paging(query, params, config) do
    {limit, offset, page} = Paging.new(params, config)
    %{query | limit: limit, offset: offset, page: page}
  end

  defp put_sorting(query, params, config) do
    sorting = Sorting.new(params, config)
    %{query | sorting: sorting}
  end

  defp put_scoping(query, params, config) do
    scoping = Scoping.new(params, config)
    %{query | scoping: scoping}
  end
end
