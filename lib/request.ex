defmodule WarrantEx.Request do
  @moduledoc """
    handle API request to GetStream
  """
  alias __MODULE__
  alias WarrantEx.Config

  defstruct base_url: nil, method: :get, path: nil, params: %{}, body: ""

  @type t() :: %Request{
          base_url: String.t() | nil,
          path: String.t() | nil,
          method: HTTPoison.method(),
          params: HTTPoison.params(),
          body: HTTPoison.body()
        }

  @spec new :: t()
  def new, do: %Request{}

  @spec with_base_url(t(), String.t()) :: t()
  def with_base_url(%Request{} = r, base_url) when is_binary(base_url) do
    %{r | base_url: base_url}
  end

  @spec with_method(t(), HTTPoison.method()) :: t()
  def with_method(%Request{} = r, method) do
    %{r | method: method}
  end

  @spec with_path(t(), String.t()) :: t()
  def with_path(%Request{} = r, path) do
    %{r | path: path}
  end

  @spec with_body(t(), Enum.t() | String.t()) :: t()
  def with_body(%Request{} = r, body) do
    body =
      case body do
        body when is_map(body) or is_list(body) -> Jason.encode!(body)
        body when is_binary(body) -> body
      end

    %{r | body: body}
  end

  @spec with_params(t(), map()) :: t()
  def with_params(%Request{} = r, params) do
    %{r | params: params}
  end

  @spec send(t()) :: {:ok, map() | String.t()} | {:error, any()}
  def send(%Request{} = r) do
    config = Config.get_config()

    headers = build_header(config)
    url = construct_url(r, config)

    r.method
    |> HTTPoison.request(url, r.body, headers, params: r.params)
    |> handle_response()
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
