defmodule WarrantEx.PricingTier do
  @moduledoc false
  alias __MODULE__
  alias WarrantEx.API
  alias WarrantEx.Feature
  alias WarrantEx.TypeUtils
  alias WarrantEx.Warrant

  @enforce_keys [:pricing_tier_id]
  defstruct [:pricing_tier_id, :name, :description]

  @type t() :: %PricingTier{
          pricing_tier_id: String.t(),
          name: String.t(),
          description: String.t()
        }

  @namespace "/v1/pricing-tiers"

  @doc """
  Create a new pricing_tier struct
  Expects a unique pricing_tier_id, and name and description
  """

  @spec new(String.t(), String.t(), String.t()) :: t()
  def new(pricing_tier_id, name, description) do
    %PricingTier{
      pricing_tier_id: pricing_tier_id,
      name: name,
      description: description
    }
  end

  @spec get(String.t()) :: {:ok, t()} | {:error, any()}
  def get(pricing_tier_id) do
    @namespace |> API.get(pricing_tier_id) |> handle_response()
  end

  @spec list(TypeUtils.list_filter() | map()) :: {:ok, [t()]} | {:error, any()}
  def list(filter \\ %{}) do
    @namespace |> API.list(filter) |> handle_response()
  end

  @spec list_features(String.t(), TypeUtils.list_filter()) ::
          {:ok, [Feature.t()]} | {:error, any()}
  def list_features(pricing_tier_id, filter) do
    namespace = "#{@namespace}/#{pricing_tier_id}/features"
    namespace |> API.list(filter) |> Feature.handle_response()
  end

  @doc """
    Create a pricing_tier or list of pricing_tiers in Warrant
    Expects a map or list of maps with the following keys:
      - pricing_tierId
      - name
      - description
  """
  @spec create(map() | [map()]) :: {:error, any} | {:ok, t() | [t()]}
  def create(params) do
    @namespace |> API.create(params) |> handle_response()
  end

  @doc """
  Updates pricing_tier in Warrant
  Expects a map with the following keys:
    - name
    - description
  Example:
    WarrantEx.PricingTier.update("pricing_tier_1", %{name: "new_name", description: "new_description"})
  """
  @spec update(String.t(), map) :: {:error, any} | {:ok, t()}
  def update(pricing_tier_id, params) do
    @namespace |> API.update(pricing_tier_id, params) |> handle_response()
  end

  @doc """
    Delete a pricing_tier or list of pricing_tiers in Warrant
    Expects a pricing_tier_id or list of maps with the following key:
      - pricing_tierId

    Example:
      WarrantEx.PricingTier.delete("pricing_tier_1")
      WarrantEx.PricingTier.delete([%{pricing_tierId: "pricing_tier_1"}, %{pricing_tierId: "pricing_tier_2"}])
  """

  @spec delete([map()] | String.t()) :: :ok
  def delete(params), do: API.delete(@namespace, params)

  @spec assign_feature(String.t(), String.t()) :: {:ok, Warrant.t()} | {:error, any()}
  def assign_feature(pricing_tier_id, feature_id) do
    namespace = "#{@namespace}/#{pricing_tier_id}/features/#{feature_id}"
    namespace |> API.create(%{}) |> Warrant.handle_response()
  end

  @spec remove_feature(String.t(), String.t()) :: :ok | {:error, any()}
  def remove_feature(pricing_tier_id, feature_id) do
    namespace = "#{@namespace}/#{pricing_tier_id}/features"
    API.delete(namespace, feature_id)
  end

  @spec handle_response({:ok, map() | [map()]} | {:error, any()}) ::
          {:ok, t() | [t()]} | {:error, any()}
  def handle_response(response) do
    case response do
      {:ok, result} when is_list(result) ->
        {:ok, Enum.map(result, &new(&1["pricingTierId"], &1["name"], &1["description"]))}

      {:ok, result} ->
        {:ok, new(result["pricingTierId"], result["name"], result["description"])}

      _ ->
        response
    end
  end
end
