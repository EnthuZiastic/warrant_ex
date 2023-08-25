defmodule WarrantEx.API do
  @moduledoc false
  alias WarrantEx.Request
  alias WarrantEx.TypeUtils

  @type namespace() :: String.t()

  @spec get(namespace(), String.t()) :: {:ok, map()} | {:error, any()}
  def get(namespace, id) do
    path = "#{namespace}/#{id}"

    Request.new()
    |> Request.with_method(:get)
    |> Request.with_path(path)
    |> Request.send()
  end

  @spec list(namespace(), TypeUtils.list_filter()) :: {:ok, list()} | {:error, any()}
  def list(namespace, filter) do
    Request.new()
    |> Request.with_method(:get)
    |> Request.with_path(namespace)
    |> Request.with_params(filter)
    |> Request.send()
  end

  @spec create(namespace()) :: {:error, any} | {:ok, map()}
  def create(namespace) do
    Request.new()
    |> Request.with_method(:post)
    |> Request.with_path(namespace)
    |> Request.send()
  end

  @spec create(namespace(), map() | [map()]) :: {:error, any} | {:ok, map() | [map()]}
  def create(namespace, params) do
    Request.new()
    |> Request.with_method(:post)
    |> Request.with_path(namespace)
    |> Request.with_body(params)
    |> Request.send()
  end

  @spec update(namespace(), String.t(), map()) :: {:error, any} | {:ok, map()}
  def update(namespace, id, params) do
    path = "#{namespace}/#{id}"

    Request.new()
    |> Request.with_method(:put)
    |> Request.with_path(path)
    |> Request.with_body(params)
    |> Request.send()
  end

  @spec delete(namespace(), [map()] | String.t()) :: :ok | {:error, any()}
  def delete(namespace, params) when is_list(params) do
    Request.new()
    |> Request.with_method(:delete)
    |> Request.with_path(namespace)
    |> Request.with_body(params)
    |> Request.send()
    |> handle_delete_response()
  end

  def delete(namespace, id) do
    path = "#{namespace}/#{id}"

    Request.new()
    |> Request.with_method(:delete)
    |> Request.with_path(path)
    |> Request.send()
    |> handle_delete_response()
  end

  defp handle_delete_response(response) do
    case response do
      {:ok, _} -> :ok
      _ -> response
    end
  end
end
