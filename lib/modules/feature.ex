defmodule WarrantEx.Feature do
  @moduledoc false
  alias __MODULE__
  alias WarrantEx.API

  @enforce_keys [:feature_id]
  defstruct [:feature_id, :name, :description]

  @type t() :: %Feature{
          feature_id: String.t(),
          name: String.t(),
          description: String.t()
        }

  @namespace "/v1/pricing-tiers"

  @doc """
  Create a new feature struct
  Expects a unique feature_id, and name and description
  """

  @spec new(String.t(), String.t(), String.t()) :: t()
  def new(feature_id, name, description) do
    %Feature{
      feature_id: feature_id,
      name: name,
      description: description
    }
  end

  @spec get(String.t()) :: {:ok, t()} | {:error, any()}
  def get(feature_id) do
    @namespace |> API.get(feature_id) |> handle_response()
  end

  @spec list(TypeUtils.list_filter() | map()) :: {:ok, [t()]} | {:error, any()}
  def list(filter \\ %{}) do
    @namespace |> API.list(filter) |> handle_response()
  end

  @doc """
    Create a feature or list of features in Warrant
    Expects a map or list of maps with the following keys:
      - featureId
      - name
      - description
  """
  @spec create(map() | [map()]) :: {:error, any} | {:ok, t() | [t()]}
  def create(params) do
    @namespace |> API.create(params) |> handle_response()
  end

  @doc """
  Updates feature in Warrant
  Expects a map with the following keys:
    - name
    - description
  Example:
    WarrantEx.Feature.update("feature_1", %{name: "new_name", description: "new_description"})
  """
  @spec update(String.t(), map) :: {:error, any} | {:ok, t()}
  def update(feature_id, params) do
    @namespace |> API.update(feature_id, params) |> handle_response()
  end

  @doc """
    Delete a feature or list of features in Warrant
    Expects a feature_id or list of maps with the following key:
      - featureId

    Example:
      WarrantEx.Feature.delete("feature_1")
      WarrantEx.Feature.delete([%{featureId: "feature_1"}, %{featureId: "feature_2"}])
  """

  @spec delete([map()] | String.t()) :: :ok
  def delete(params), do: API.delete(@namespace, params)

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
