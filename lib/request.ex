defmodule WarrantEx.Request do
  @moduledoc """
    handle API request to GetStream
  """
  alias __MODULE__
  alias WarrantEx.Config

  defstruct [:base_url, :path, :method, :params, :body, :options]

  @type t() :: %Request{
          base_url: String.t(),
          path: String.t(),
          method: HTTPoison.method(),
          params: map(),
          body: map(),
          options: list()
        }

  def new, do: %Request{}

  def with_method(%Request{} = r, method) do
    %{r | method: method}
  end

  def with_path(%Request{} = r, path) do
    %{r | path: path}
  end

  def with_body(%Request{} = r, body) do
    %{r | body: body}
  end

  def with_params(%Request{} = r, params) do
    %{r | params: params}
  end

  def send(%Request{} = r) do
    config = Config.get_config()

    headers = build_header(config)
    url = construct_url(r, config)

    body =
      case r.body do
        body when is_map(body) or is_list(body) -> Jason.encode!(body)
        body when is_binary(body) -> body
        nil -> ""
      end

    r.method
    |> HTTPoison.request(url, body, headers)
    |> IO.inspect()
    |> handle_response()
    |> IO.inspect()
  end

  defp build_header(config) do
    [
      {"Content-Type", "application/json"},
      {"Authorization", "ApiKey #{config.api_key}"}
    ]
  end

  defp construct_url(%Request{} = r, config) do
    base_url = r.base_url || config.base_url

    case r.path do
      path when is_binary(path) -> "#{base_url}#{path}"
      nil -> base_url
    end
  end

  defp handle_response({:ok, %HTTPoison.Response{body: body, status_code: code}})
       when code in [200, 201] do
    {:ok, json_or_value(body)}
  end

  defp handle_response({:ok, %HTTPoison.Response{body: body}}) do
    {:error, json_or_value(body)}
  end

  defp handle_response({:error, %HTTPoison.Error{reason: reason}}) do
    {:error, json_or_value(reason)}
  end

  defp json_or_value(data) when is_binary(data) do
    case Jason.decode(data) do
      {:ok, parsed_value} -> parsed_value
      _ -> data
    end
  end

  defp json_or_value(data), do: data
end
