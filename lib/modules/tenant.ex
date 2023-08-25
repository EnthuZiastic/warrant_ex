defmodule WarrantEx.Tenant do
  @moduledoc false
  alias __MODULE__
  alias WarrantEx.API
  alias WarrantEx.TypeUtils
  alias WarrantEx.Warrant

  @enforce_keys [:tenant_id]
  defstruct [:tenant_id, :name]

  @type t() :: %Tenant{
          tenant_id: String.t(),
          name: String.t()
        }

  @namespace "/v1/tenants"

  @doc """
  Create a new tenant struct
  Expects a unique tenant_id, and name
  """

  @spec new(String.t(), String.t()) :: WarrantEx.Tenant.t()
  def new(tenant_id, name) do
    %Tenant{
      tenant_id: tenant_id,
      name: name
    }
  end

  @spec get(String.t()) :: {:ok, Tenant.t()} | {:error, any()}
  def get(tenant_id) do
    @namespace |> API.get(tenant_id) |> handle_response()
  end

  @spec list(TypeUtils.list_filter()) :: {:ok, [Tenant.t()]} | {:error, any()}
  def list(filter) do
    @namespace |> API.list(filter) |> handle_response()
  end

  @doc """
    Create a tenant or list of tenants in Warrant
    Expects a map or list of maps with the following keys:
      - tenantId
      - name
  """
  @spec create(map() | [map()]) :: {:error, any} | {:ok, Tenant.t() | [Tenant.t()]}
  def create(params) do
    @namespace |> API.create(params) |> handle_response()
  end

  @doc """
  Updates tenant in Warrant
  Expects a map with the following key:
    - name

  Example:
    WarrantEx.Tenant.update("tenant_1", %{name: "new_name"})
  """
  @spec update(String.t(), map) :: {:error, any} | {:ok, Tenant.t()}
  def update(tenant_id, params) do
    @namespace |> API.update(tenant_id, params) |> handle_response()
  end

  @doc """
    Delete a tenant or list of tenants in Warrant
    Expects a tenant_id or list of maps with the following key:
      - tenantId

    Example:
      WarrantEx.Tenant.delete("tenant_1")
      WarrantEx.Tenant.delete([%{tenantId: "tenant_1"}, %{tenantId: "tenant_2"}])
  """

  @spec delete([map()] | String.t()) :: :ok
  def delete(params) when is_list(params), do: API.delete(@namespace, params)

  @spec assign_user(String.t(), String.t()) :: {:ok, map()} | {:error, any()}
  def assign_user(tenant_id, user_id) do
    path = "#{@namespace}/#{tenant_id}/users/#{user_id}"
    path |> API.create() |> Warrant.handle_response()
  end

  defp handle_response(response) do
    case response do
      {:ok, result} when is_list(result) ->
        {:ok, Enum.map(result, &new(&1["tenantId"], &1["name"]))}

      {:ok, result} ->
        {:ok, new(result["tenantId"], result["name"])}

      _ ->
        response
    end
  end
end
