defmodule Query do
  @moduledoc """
  Query adds simple tools to aid the use of Ecto in web settings. With it, we can
  add paging, scopes, and sorting with ease. At its heart, Query lets us build
  complex queries from our controller params.

  Before starting, we should configure Query. At a minimum, we need to add an Ecto
  Repo from which to work with. 

      config :query, [
        repo: App.Repo
      ]

  Query is split into two main components:

    * `Query.Builder` - the builder readies our query paging, sorting, and
    scopes based on the provided params. The builder does not touch the database.

    * `Query.Result` - the result takes our builder, composes the final query,
    and fetches the data from our repo. It will also provide additional meta
    details that we can provide back to the user.

  We can now compose complex queries from our controller.

      defmodule App.PostController do
        use App, :controller

        @options [
          sorting: [permitted: ["id", "title", "created_at"]],
          scopes: [{App.Context, "by_title"}]
        ]

        def index(conn, params) do
          result = App.Post
          |> Query.builder(params, @options)
          |> Query.result()
          render(conn, "index.json", result: result)
        end
      end
  
  Given the controller above, we can now pass the following query options.

  `/posts?sort_by=created_at&direction=desc&by_title=test`

  We are able to sort by `created_at`, as we permitted it in our sorting options.
  By default, we are not allowed to sort by any attribute. They must be whitelisted
  first.

  We are also able to pass the `by_title` query param. Once again, this is only
  possible as we whitelisted it in our list of scopes. Scopes are passed in the
  following format: `{App.Context, "by_title"}`. The first item in the tuple is
  the module that contains the function from which we will use to query against.
  The second item is the query param as well as function name.

  So given the above, we must have an `App.Context` module that contains a
  `by_title` function. This function must have an arity of 2 - with the first argument
  being an `Ecto.Queryable` and the second argument being the value that we
  are querying with. In the above case, it would be "test".
  """

  alias Query.{Builder, Result}

  @doc """
  Creates a new Query.Builder struct.

  ## Parameters

    - queryable: Any Ecto queryable.
    - params: A param map - most likely from a controller.
    - options: A keyword list of options.

  ## Options
    * `:repo` - the Ecto repo from which to work with.
    * `:paging` - a list of paging options. For more info, see __.
    * `:sorting` - a list of sorting options. For more info, see __.
    * `:scopes` - a list of scope options. For more info, see __.

  ## Examples

      iex> Query.builder(App.Post)
      %Query.Builder{limit: 20, offset: 0, page: 1,
      queryable: #Ecto.Query<from p in App.Post>, repo: App.Repo,
      scopes: [], sorting: [asc: :id]}
  """
  @spec builder(Ecto.Queryable.t, Query.Builder.param, list) :: Query.Builder.t
  def builder(queryable, params \\ %{}, options \\ []) do
    Builder.new(queryable, params, options)
  end

  @doc """
  Creates a new Query.Result struct from a Query.Builder.

  ## Parameters

    - builder: A Query.Builder struct.

  ## Examples

      iex> Query.result(builder)
      %Query.Result{data: [
      %App.Post{body: "Body 1", title: "Title 1"},
      %App.Post{body: "Body 2", id: 840, title: "Title 2"}],
      meta: %{page: 1, page_total: 2, total: 2, total_pages: 1}}
  """
  @spec builder(Query.Builder.t) :: Query.Result.t
  def result(builder) do
    Result.new(builder)
  end

  @doc """
  Creates a new Query.Builder struct, runs it, and returns a Query.Result struct.

  This is a shortend version of `App.Post |> Query.builder() |> Query.result()`

  ## Parameters

    - queryable: Any Ecto queryable.
    - params: A param map - most likely from a controller.
    - options: A keyword list of options.

  ## Options
    * `:repo` - the Ecto repo from which to work with.
    * `:paging` - a list of paging options. For more info, see __.
    * `:sorting` - a list of sorting options. For more info, see __.
    * `:scopes` - a list of scope options. For more info, see __.

  ## Examples

      iex> Query.builder(App.Post)
      %Query.Builder{limit: 20, offset: 0, page: 1,
      queryable: #Ecto.Query<from p in App.Post>, repo: App.Repo,
      scopes: [], sorting: [asc: :id]}
  """
  @spec builder(Ecto.Queryable.t, Query.Builder.param, list) :: Query.Result.t
  def run(queryable, params \\ %{}, options \\ []) do
    queryable
    |> builder(params, options)
    |> result()
  end
end
