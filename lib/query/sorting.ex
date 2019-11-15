defmodule Query.Sorting do
  @moduledoc false

  @doc false
  def new(params, config) do
    dir = fetch_dir(params, config)
    sort = fetch_sort(params, config)

    [{dir, sort}]
  end

  defp fetch_dir(params, config) when is_map(params) do
    dir = Map.get(params, config.dir_param)
    fetch_dir(dir, config.dir_default)
  end

  defp fetch_dir("asc", _), do: :asc
  defp fetch_dir("desc", _), do: :desc
  defp fetch_dir(_, dir_default), do: String.to_atom(dir_default)

  defp fetch_sort(params, config) do
    sort_by = Map.get(params, config.sort_param, config.sort_default)

    case Enum.member?(config.sort_permitted, sort_by) do
      true -> String.to_atom(sort_by)
      false -> String.to_atom(config.sort_default)
    end
  end
end
