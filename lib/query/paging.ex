defmodule Query.Paging do
  @moduledoc false

  @doc false
  def new(params, opts) do
    page = get_page(params, opts)
    limit = get_limit(params, opts)
    offset = (page - 1) * limit

    {limit, offset, page}
  end

  defp get_page(params, opts) do
    get_and_parse(params, opts.page_param, opts.page_default)
  end

  defp get_limit(params, opts) do
    limit = get_and_parse(params, opts.limit_param, opts.limit_default)
    if limit <= opts.limit_max, do: limit, else: opts.limit_max
  end

  defp get_and_parse(params, key, default) do
    params
    |> Map.get(key)
    |> parse_integer(default)
  end

  defp parse_integer(integer, _default) when is_integer(integer) and integer >= 0, do: integer

  defp parse_integer(string, default) when is_binary(string) do
    case Integer.parse(string) do
      {integer, _} -> parse_integer(integer, default)
      _ -> default
    end
  end

  defp parse_integer(_, default), do: default
end
