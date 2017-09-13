# Query

Query adds simple tools to aid the use of Ecto in web settings. With it, we can
add paging, scopes, and sorting without much fuss.


## Basics

At the core of Query are the `Query.Builder` struct and `Query.Result` struct. We use the `Query.Builder` to retrieve
data for our `Query.Result`. 

Given an `App.Post` schema, we can create a builder that will help us retrieve our results.

```elixir
iex(1)> builder = Query.builder(App.Post)

%Query.Builder{limit: 20, offset: 0, page: 1,
queryable: #Ecto.Query<from p in App.Post>, repo: App.Repo,
scopes: [], sorting: [asc: :id]}

iex(2)> Query.result(builder)

%Query.Result{data: [%App.Post{__meta__: #Ecto.Schema.Metadata<:loaded, "posts">,
   body: "Body 1",
   comments: #Ecto.Association.NotLoaded<association :comments is not loaded>,
   id: 839, inserted_at: ~N[2017-09-13 02:57:33.170049], published: false,
   title: "Title 1", updated_at: ~N[2017-09-13 02:57:33.170054]},
  %App.Post{__meta__: #Ecto.Schema.Metadata<:loaded, "posts">,
   body: "Body 2",
   comments: #Ecto.Association.NotLoaded<association :comments is not loaded>,
   id: 840, inserted_at: ~N[2017-09-13 02:57:33.172312], published: false,
   title: "Title 2", updated_at: ~N[2017-09-13 02:57:33.172317]}],
 meta: %{page: 1, page_total: 2, total: 2}}
```

## Paging

We can page our data by provding the params from our controllers. By default, Query uses the "page" query param for the page number, and the "limit" query param for the max number of items. The default page is 1, and the default limit is 20. All of this is configurable.

```elixir
iex(1)> App.Post 
|> Query.builder(%{"page" => 2, "limit" => 10})
|> Query.result()

%Query.Result{data: [], meta: %{page: 2, page_total: 0, total: 2}}
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

%Query.Result{data: [], meta: %{page: 2, page_total: 0, total: 2}}
```

## Sorting

We can sort our data by providing the params from our controllers. By default, Query uses the "sort_by" query param for the sort attribute, and the "direction" query param for the order. All attributes that can be used for sorting must be
whitelisted. We do this by passing the `[sorting: [permitted: []]]` options to our builder. By default, we sort by "id" in the "asc" direction. All of this is configurable.

```elixir
iex(1)> App.Post
|> Query.builder(%{"sort_by" => "id", "direction" => "desc"}, [sorting: [permitted: ["id", "title"]]])
|> Query.result()

%Query.Result{data: [%App.Post{__meta__: #Ecto.Schema.Metadata<:loaded, "posts">,
   body: "Body 2",
   comments: #Ecto.Association.NotLoaded<association :comments is not loaded>,
   id: 840, inserted_at: ~N[2017-09-13 02:57:33.170049], published: false,
   title: "Title 2", updated_at: ~N[2017-09-13 02:57:33.170054]},
  %App.Post{__meta__: #Ecto.Schema.Metadata<:loaded, "posts">,
   body: "Body 1",
   comments: #Ecto.Association.NotLoaded<association :comments is not loaded>,
   id: 839, inserted_at: ~N[2017-09-13 02:57:33.172312], published: false,
   title: "Title 1", updated_at: ~N[2017-09-13 02:57:33.172317]}],
 meta: %{page: 1, page_total: 2, total: 2}}
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
|> Query.builder(%{"sort_by" => "id", "dir" => "desc"}, [sorting: [dir_param: "dir", permitted: ["id", "title"]]])
|> Query.result()

%Query.Result{data: [%App.Post{__meta__: #Ecto.Schema.Metadata<:loaded, "posts">,
   body: "Body 2",
   comments: #Ecto.Association.NotLoaded<association :comments is not loaded>,
   id: 840, inserted_at: ~N[2017-09-13 02:57:33.170049], published: false,
   title: "Title 2", updated_at: ~N[2017-09-13 02:57:33.170054]},
  %App.Post{__meta__: #Ecto.Schema.Metadata<:loaded, "posts">,
   body: "Body 1",
   comments: #Ecto.Association.NotLoaded<association :comments is not loaded>,
   id: 839, inserted_at: ~N[2017-09-13 02:57:33.172312], published: false,
   title: "Title 1", updated_at: ~N[2017-09-13 02:57:33.172317]}],
 meta: %{page: 1, page_total: 2, total: 2}}
```


## Scoping

We can scope our data by providing the params from our controller. By default, Query has no scopes applied. Any query param scopes must be whitelisted. 

More info coming soon.


## Installation

This package can be installed by adding `query` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:query, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/query](https://hexdocs.pm/query).

