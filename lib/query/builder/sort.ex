defmodule Query.Builder.Sort do
  @moduledoc """
  Provides sort details for our Query.Builder.
  """

  @defaults [
    default_sort: "id",
    default_dir: "asc",
    sort_param: "sort_by",
    dir_param: "direction",
    permitted: []
  ]

  @doc """
  Provides sorting details based on the provided params and options.

  ## Parameters

    - params: A param map - most likely from a controller.
    - options: A list of options.

  ## Options
    * `:default_sort` - the default sort attribute if none is provided. Defaults to "id".
    * `:default_dir` - the default direction. Defaults to "asc".
    * `:sort_param` - the param key to use for the sort. Deafults to "sort_by".
    * `:dir_param` - the param key to use for the direction. Defaults to "direction".
    * `:permitted` - a list of permitted attributes that we can sort on.


  ## Examples

      iex> Query.Builder.Sort.new(%{"sort_by" => "title", "direction" => "desc"}, %{permitted: ["title"]})
      [{:desc, :title}]
  """
  @spec new(Query.Builder.param, list) :: [{atom, atom}]
  def new(params \\ %{}, options \\ []) do
    options = Keyword.merge(@defaults, options)
    dir     = fetch_dir(params, options)
    sort    = fetch_sort(params, options)
    [{dir, sort}]
  end

  defp fetch_dir(params, options) when is_map(params) do
    dir_param    = Keyword.fetch!(options, :dir_param)
    default_dir  = Keyword.fetch!(options, :default_dir)
    dir          = Map.get(params, dir_param) || default_dir
    fetch_dir(dir, default_dir)
  end
  defp fetch_dir("asc", _), do: :asc
  defp fetch_dir("desc", _), do: :desc
  defp fetch_dir(_, default_dir), do: String.to_atom(default_dir)

  defp fetch_sort(params, options) when is_map(params) do
    sort_param   = Keyword.fetch!(options, :sort_param)
    default_sort = Keyword.fetch!(options, :default_sort)
    permitted    = Keyword.fetch!(options, :permitted)
    sort_by      = Map.get(params, sort_param) || default_sort
    case Enum.member?(permitted, sort_by) do
      true  -> String.to_atom(sort_by)
      false -> String.to_atom(default_sort)
    end
  end
end
