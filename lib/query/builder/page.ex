defmodule Query.Builder.Page do
  @defaults %{
    default_page: 1,
    default_limit: 20,
    limit_param: "limit",
    page_param: "page"
  }

  def new(params \\ %{}, options \\ %{}) do
    options = Map.merge(@defaults, options)
    page    = fetch_page(params, options)
    limit   = fetch_limit(params, options)
    offset  = (page - 1) * limit
    {limit, offset, page}
  end

  defp fetch_page(params, options) do
    page = params[options.page_param] || options.default_page
    parse_integer(page, options.default_page)
  end

  defp fetch_limit(params, options) do
    limit = params[options.limit_param] || options.default_limit
    parse_integer(limit, options.default_limit)
    if limit <= options.default_limit, do: limit, else: options.default_limit
  end

  defp parse_integer(integer, _) when is_integer(integer) do
    integer
  end
  defp parse_integer(string, default) when is_binary(string) do
    case Integer.parse(string) do
      {integer, _} -> integer
      _            -> default
    end
  end
end
