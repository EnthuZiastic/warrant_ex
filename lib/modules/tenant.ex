defmodule WarrantEx.Tenant do
  @moduledoc false
  alias __MODULE__
  alias WarrantEx.API
  alias WarrantEx.PricingTier
  alias WarrantEx.TypeUtils
  alias WarrantEx.User
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

  def list_users(tenant_id, filter) do
    namespace = "#{@namespace}/#{tenant_id}/users"
    namespace |> API.list(filter) |> User.handle_response()
  end

  @spec list_pricing_tiers(String.t(), TypeUtils.list_filter()) ::
          {:ok, [PricingTier.t()]} | {:error, any()}
  def list_pricing_tiers(tenant_id, filter) do
    namespace = "#{@namespace}/#{tenant_id}/pricing-tiers"
    namespace |> API.list(filter) |> PricingTier.handle_response()
  end

  @spec list_features(String.t(), TypeUtils.list_filter()) ::
          {:ok, [Feature.t()]} | {:error, any()}
  def list_features(tenant_id, filter) do
    namespace = "#{@namespace}/#{tenant_id}/features"
    namespace |> API.list(filter) |> WarrantEx.Feature.handle_response()
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
  def delete(params), do: API.delete(@namespace, params)

  @spec assign_user(String.t(), String.t()) :: {:ok, map()} | {:error, any()}
  def assign_user(tenant_id, user_id) do
    namespace = "#{@namespace}/#{tenant_id}/users/#{user_id}"
    namespace |> API.create() |> Warrant.handle_response()
  end

  @spec assign_pricing_tier(String.t(), String.t()) :: {:ok, map()} | {:error, any()}
  def assign_pricing_tier(tenant_id, pricing_tier_id) do
    namespace = "#{@namespace}/#{tenant_id}/pricing-tiers/#{pricing_tier_id}"
    namespace |> API.create() |> Warrant.handle_response()
  end

  @spec assing_feature(String.t(), String.t()) :: {:ok, map()} | {:error, any()}
  def assing_feature(tenant_id, feature_id) do
    namespace = "#{@namespace}/#{tenant_id}/features/#{feature_id}"
    namespace |> API.create() |> Warrant.handle_response()
  end

  @spec remove_user(String.t(), String.t()) :: :ok | {:error, any()}
  def remove_user(tenant_id, user_id) do
    namespace = "#{@namespace}/#{tenant_id}/users"
    API.delete(namespace, user_id)
  end

  @spec remove_pricing_tier(String.t(), String.t()) :: :ok | {:error, any()}
  def remove_pricing_tier(tenant_id, pricing_tier_id) do
    namespace = "#{@namespace}/#{tenant_id}/pricing-tiers"
    API.delete(namespace, pricing_tier_id)
  end

  @spec remove_feature(String.t(), String.t()) :: :ok | {:error, any()}
  def remove_feature(tenant_id, feature_id) do
    namespace = "#{@namespace}/#{tenant_id}/features"
    API.delete(namespace, feature_id)
  end

  @spec handle_response({:ok, map() | [map()]} | {:error, any()}) ::
          {:ok, t() | [t()]} | {:error, any()}
  def handle_response(response) do
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
