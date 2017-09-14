# Query

Query adds simple tools to aid the use of Ecto in web settings. With it, we can
add paging, scopes, and sorting with ease. At its heart, Query lets us build
complex queries from our controller params.

Before starting, we should configure Query. At a minimum, we need to add an Ecto
Repo from which to work with. 

```elixir
config :query, [
  repo: App.Repo
]
```

Query is split into two main components:

  * `Query.Builder` - the builder readies our query paging, sorting, and
  scopes based on the provided params. The builder does not touch the database.

  * `Query.Result` - the result takes our builder, composes the final query,
  and fetches the data from our repo. It will also provide additional meta
  details that we can provide back to the user.

We can now compose complex queries from our controller.

```elixir
defmodule App.PostController do
  use App, :controller

  @options [
    sorting: %{permitted: ["id", "title", "created_at"]},
    scopes: [{App.Context, "by_title"}]
  ]

  def index(conn, params) do
    # This would most likely be moved into our "context" - this is just an example.
    # Using a context, we could instead do:
    #
    # result = App.Context.list_posts(params, @options)
    #
    result = App.Post
    |> Query.builder(params, @options)
    |> Query.result()
    render(conn, "index.json", posts: result)
  end
end
```
  
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

## Basics

At the core of Query are the `Query.Builder` struct and `Query.Result` struct. We use
the `Query.Builder` to compose our query, and the `Query.Result` to fetch our data.

Given an `App.Post` schema, we can create a builder that will help us retrieve our results.

```elixir
iex(1)> builder = Query.builder(App.Post)

%Query.Builder{limit: 20, offset: 0, page: 1,
queryable: #Ecto.Query<from p in App.Post>, repo: App.Repo,
scopes: [], sorting: [asc: :id]}

iex(2)> Query.result(builder)

%Query.Result{data: [
  %App.Post{body: "Body 1", id: 839, title: "Title 1"},
  %App.Post{body: "Body 2", id: 840, title: "Title 2"}],
 meta: %{page: 1, page_total: 2, total: 2, total_pages: 1}}
```

## Paging

We can page our data by providing the params from our controllers. By default, Query uses the "page" query param for the page number, and the "limit" query param for the max number of items. The default page is 1, and the default limit is 20. All of this is configurable.

```elixir
iex(1)> App.Post 
|> Query.builder(%{"page" => 2, "limit" => 10})
|> Query.result()

%Query.Result{data: [], meta: %{page: 2, page_total: 0, total: 2, total_pages: 1}}
```

We can configure all of our paging details.

```elixir
config :query, [
  paging: %{
    default_page: 1,
    default_limit: 20,
    limit_param: "limit",
    page_param: "page"
  }
]
```

Alternatively, we can pass our paging config via options to the builder.

```elixir
iex(1)> App.Post
|> Query.builder(%{"page" => 2, "per" => 10}, [paging: %{limit_param: "per"}])
|> Query.result()

%Query.Result{data: [], meta: %{page: 2, page_total: 0, total: 2, total_pages: 1}}
```

## Sorting

We can sort our data by providing the params from our controllers. By default, Query uses the "sort_by" query param for the sort attribute, and the "direction" query param for the order. All attributes that can be used for sorting must be
whitelisted. We do this by passing the `[sorting: [permitted: []]]` options to our builder. By default, we sort by "id" in the "asc" direction. All of this is configurable.

```elixir
iex(1)> App.Post
|> Query.builder(%{"sort_by" => "id", "direction" => "desc"}, [sorting: %{permitted: ["id", "title"]}])
|> Query.result()

%Query.Result{data: [
  %App.Post{body: "Body 2", id: 840,title: "Title 2"},
  %App.Post{body: "Body 1", id: 839, title: "Title 1"}],
 meta: %{page: 1, page_total: 2, total: 2, total_pages: 1}}
```

We can configure all of our sorting details.

```elixir
config :query, [
  sorting: %{
    default_sort: "id",
    default_dir: "asc",
    sort_param: "sort_by",
    dir_param: "direction"
  }
]
```

Alternatively, we can pass our sorting config via options to the builder.

```elixir
iex(1)> App.Post
|> Query.builder(%{"sort_by" => "id", "dir" => "desc"}, [sorting: %{dir_param: "dir", permitted: ["id", "title"]}])
|> Query.result()

%Query.Result{data: [
  %App.Post{body: "Body 2", id: 840,title: "Title 2"},
  %App.Post{body: "Body 1", id: 839, title: "Title 1"}],
 meta: %{page: 1, page_total: 2, total: 2, total_pages: 1}}
```

## Scoping

We can scope our data by providing the params from our controller. By default, Query has no scopes applied. Any query param scopes must be whitelisted. We do this by passing the `[scopes: [{App.Context, "by_title"}]]` options to our builder.

A scope must be made up of a two item tuple. The first item must be a module. The second item must be a function
within the module, in binary format. The function must have an arity of 2 - with the first argument being an `Ecto.Queryable` and the second argument being the value of the query param passed.

So, given the above scope, we could assume we have the following:

```elixir
defmodule App.Context do
  import Ecto.Query

  def by_title(queryable, value) do
    where(queryable, [p], p.title == ^value)
  end
end
```

Which would allow us to do:

```elixir
iex(1)> App.Post
|> Query.builder(%{"by_title" => "Title 1"}, [scopes: [{App.Context, "by_title"}]])
|> Query.result()

%Query.Result{data: [
  %App.Post{body: "Body 1", id: 839, title: "Title 1"}],
 meta: %{page: 1, page_total: 1, total: 2, total_pages: 1}}
```

## Installation

This package can be installed by adding `query` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:query, "~> 0.1.3"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/query](https://hexdocs.pm/query).

