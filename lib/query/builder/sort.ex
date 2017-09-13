defmodule Query.Builder.Sort do
  @defaults %{
    default_sort: "id",
    default_dir: "asc",
    sort_param: "sort_by",
    dir_param: "direction",
    permitted: []
  }

  def new(params \\ %{}, options \\ %{}) do
    options = Map.merge(@defaults, options)
    dir     = fetch_dir(params, options)
    sort    = fetch_sort(params, options)
    [{dir, sort}]
  end

  def fetch_dir(params, options) when is_map(params) do
    dir = params[options.dir_param] || options.default_dir
    fetch_dir(dir, options)
  end
  def fetch_dir("asc", _), do: :asc
  def fetch_dir("desc", _), do: :desc
  def fetch_dir(_, options), do: String.to_atom(options.default_dir)

  def fetch_sort(params, options) when is_map(params) do
    sort_by = params[options.sort_param] || options.default_sort
    case Enum.member?(options.permitted, sort_by) do
      true  -> String.to_atom(sort_by)
      false -> String.to_atom(options.default_sort)
    end
  end
end
