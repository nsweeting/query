defmodule Query.Builder.Page do
  @moduledoc """
  Provides paging details for our Query.Builder.
  """

  @defaults [
    default_page: 1,
    default_limit: 20,
    limit_param: "limit",
    page_param: "page"
  ]

  @doc """
  Provides paging details based on the provided params and options.

  ## Parameters

    - params: A param map - most likely from a controller.
    - options: A list of options.

  ## Options
    * `:default_page` - the default page if none is provided. Defaults to 1.
    * `:default_limit` - the default limit. Defaults to 20.
    * `:limit_param` - the param key to use for the limit. Deafults to "limit".
    * `:page_param` - the param key to use for the page. Defaults to "page".

  ## Examples

      iex> Query.Builder.Page.new(%{"page" => 2, "per" => 10}, %{"limit_param" => "per"})
      {10, 20, 2}
  """
  @spec new(Query.Builder.param, list) :: {integer, integer, integer}
  def new(params \\ %{}, options \\ []) do
    options = Keyword.merge(@defaults, options)
    page    = fetch_page(params, options)
    limit   = fetch_limit(params, options)
    offset  = (page - 1) * limit
    {limit, offset, page}
  end

  defp fetch_page(params, options) do
    page_param  = Keyword.fetch!(options, :page_param)
    get_and_parse(params, page_param) || Keyword.fetch!(options, :default_page)
  end

  defp fetch_limit(params, options) do
    limit_param   = Keyword.fetch!(options, :limit_param)
    default_limit = Keyword.fetch!(options, :default_limit)
    limit         = get_and_parse(params, limit_param) || default_limit
    if limit <= default_limit, do: limit, else: default_limit
  end

  defp get_and_parse(params, key) do
     params
     |> Map.get(key)
     |> parse_integer()
  end

  defp parse_integer(integer) when is_integer(integer), do: integer
  defp parse_integer(string) when is_binary(string) do
    case Integer.parse(string) do
      {integer, _} -> integer
      _            -> nil
    end
  end
  defp parse_integer(_), do: nil
end
