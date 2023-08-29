defmodule WarrantEx.User do
  @moduledoc false
  alias __MODULE__
  alias WarrantEx.API
  alias WarrantEx.Feature
  alias WarrantEx.Permission
  alias WarrantEx.PricingTier
  alias WarrantEx.Role
  alias WarrantEx.Tenant
  alias WarrantEx.TypeUtils
  alias WarrantEx.Warrant

  @enforce_keys [:user_id]
  defstruct [:user_id, :email, :created_at]

  @type t() :: %User{
          user_id: String.t(),
          email: String.t(),
          created_at: DateTime.t()
        }

  @namespace "/v1/users"

  @doc """
  Create a new user struct
  Expects a unique user_id, and email and created_at
  """

  @spec new(String.t(), String.t(), String.t()) :: t()
  def new(user_id, email, created_at) do
    {:ok, dt, _} = DateTime.from_iso8601(created_at)

    %User{
      user_id: user_id,
      email: email,
      created_at: dt
    }
  end

  @spec get(String.t()) :: {:ok, t()} | {:error, any()}
  def get(user_id) do
    @namespace |> API.get(user_id) |> handle_response()
  end

  @spec list(TypeUtils.list_filter()) :: {:ok, [t()]} | {:error, any()}
  def list(filter) do
    @namespace |> API.list(filter) |> handle_response()
  end

  @spec list_tenants(String.t(), TypeUtils.list_filter()) ::
          {:ok, [Tenant.t()]} | {:error, any()}
  def list_tenants(user_id, filter) do
    namespace = "#{@namespace}/#{user_id}/tenants"
    namespace |> API.list(filter) |> Tenant.handle_response()
  end

  @spec list_permissions(String.t(), TypeUtils.list_filter()) ::
          {:ok, [Permission.t()]} | {:error, any()}
  def list_permissions(user_id, filter) do
    namespace = "#{@namespace}/#{user_id}/permissions"
    namespace |> API.list(filter) |> Permission.handle_response()
  end

  @spec list_roles(String.t(), TypeUtils.list_filter()) ::
          {:ok, [Role.t()]} | {:error, any()}
  def list_roles(user_id, filter) do
    namespace = "#{@namespace}/#{user_id}/roles"
    namespace |> API.list(filter) |> Role.handle_response()
  end

  @spec list_pricing_tiers(String.t(), TypeUtils.list_filter()) ::
          {:ok, [PricingTier.t()]} | {:error, any()}
  def list_pricing_tiers(user_id, filter) do
    namespace = "#{@namespace}/#{user_id}/pricing-tiers"
    namespace |> API.list(filter) |> PricingTier.handle_response()
  end

  @spec list_features(String.t(), TypeUtils.list_filter()) ::
          {:ok, [Feature.t()]} | {:error, any()}
  def list_features(user_id, filter) do
    namespace = "#{@namespace}/#{user_id}/features"
    namespace |> API.list(filter) |> Feature.handle_response()
  end

  @doc """
    Create a user or list of users in Warrant
    Expects a map or list of maps with the following keys:
      - userId
      - email
  """
  @spec create(map() | [map()]) :: {:error, any} | {:ok, t() | [t()]}
  def create(params) do
    @namespace |> API.create(params) |> handle_response()
  end

  @doc """
  Updates user in Warrant
  Expects a map with the following key:
    - email
  Example:
    WarrantEx.User.update("user_1", %{email: "new_email"})
  """
  @spec update(String.t(), map) :: {:error, any} | {:ok, t()}
  def update(user_id, params) do
    @namespace |> API.update(user_id, params) |> handle_response()
  end

  @doc """
    Delete a user or list of users in Warrant
    Expects a user_id or list of maps with the following key:
      - userId

    Example:
      WarrantEx.User.delete("user_1")
      WarrantEx.User.delete([%{userId: "user_1"}, %{userId: "user_2"}])
  """

  @spec delete([map()] | String.t()) :: :ok
  def delete(params), do: API.delete(@namespace, params)

  @spec assign_permission(String.t(), String.t()) :: {:ok, Warrant.t()} | {:error, any()}
  def assign_permission(user_id, permission_id) do
    namespace = "#{@namespace}/#{user_id}/permissions/#{permission_id}"
    namespace |> API.create() |> Warrant.handle_response()
  end

  @spec assign_role(String.t(), String.t()) :: {:ok, Warrant.t()} | {:error, any()}
  def assign_role(user_id, role_id) do
    namespace = "#{@namespace}/#{user_id}/roles/#{role_id}"
    namespace |> API.create() |> Warrant.handle_response()
  end

  @spec assign_pricing_tier(String.t(), String.t()) :: {:ok, Warrant.t()} | {:error, any()}
  def assign_pricing_tier(user_id, pricing_tier_id) do
    namespace = "#{@namespace}/#{user_id}/pricing-tiers/#{pricing_tier_id}"
    namespace |> API.create() |> Warrant.handle_response()
  end

  @spec assign_feature(String.t(), String.t()) :: {:ok, Warrant.t()} | {:error, any()}
  def assign_feature(user_id, feature_id) do
    namespace = "#{@namespace}/#{user_id}/features/#{feature_id}"
    namespace |> API.create() |> Warrant.handle_response()
  end

  @spec remove_permission(String.t(), String.t()) :: :ok | {:error, any()}
  def remove_permission(user_id, permission_id) do
    namespace = "#{@namespace}/#{user_id}/permissions"
    API.delete(namespace, permission_id)
  end

  @spec remove_role(String.t(), String.t()) :: :ok | {:error, any()}
  def remove_role(user_id, role_id) do
    namespace = "#{@namespace}/#{user_id}/roles"
    API.delete(namespace, role_id)
  end

  @spec remove_pricing_tier(String.t(), String.t()) :: :ok | {:error, any()}
  def remove_pricing_tier(user_id, pricing_tier_id) do
    namespace = "#{@namespace}/#{user_id}/pricing-tiers"
    API.delete(namespace, pricing_tier_id)
  end

  @spec remove_feature(String.t(), String.t()) :: :ok | {:error, any()}
  def remove_feature(user_id, feature_id) do
    namespace = "#{@namespace}/#{user_id}/features"
    API.delete(namespace, feature_id)
  end

  @spec handle_response({:ok, map() | [map()]} | {:error, any()}) ::
          {:ok, t() | [t()]} | {:error, any()}
  def handle_response(response) do
    case response do
      {:ok, result} when is_list(result) ->
        {:ok, Enum.map(result, &new(&1["userId"], &1["email"], &1["createdAt"]))}

      {:ok, result} ->
        {:ok, new(result["userId"], result["email"], result["createdAt"])}

      _ ->
        response
    end
  end
end
