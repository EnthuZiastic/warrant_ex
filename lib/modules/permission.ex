defmodule WarrantEx.Permission do
  @moduledoc false
  alias __MODULE__
  alias WarrantEx.API
  alias WarrantEx.TypeUtils

  @enforce_keys [:permission_id, :name]
  defstruct [:permission_id, :name, :description]

  @type t() :: %Permission{
          permission_id: String.t(),
          name: String.t(),
          description: String.t()
        }

  @namespace "/v1/permissions"

  @doc """
  Create a new permission struct
  Expects a unique permission_id, and name and description
  """

  @spec new(String.t(), String.t(), String.t()) :: t()
  def new(permission_id, name, description) do
    %Permission{
      permission_id: permission_id,
      name: name,
      description: description
    }
  end

  @spec get(String.t()) :: {:ok, t()} | {:error, any()}
  def get(permission_id) do
    @namespace |> API.get(permission_id) |> handle_response()
  end

  @spec list(TypeUtils.list_filter() | map()) :: {:ok, [t()]} | {:error, any()}
  def list(filter \\ %{}) do
    @namespace |> API.list(filter) |> handle_response()
  end

  @doc """
    Create a permission or list of permissions in Warrant
    Expects a map or list of maps with the following keys:
      - permissionId
      - name
      - description
  """
  @spec create(map() | [map()]) :: {:error, any} | {:ok, t() | [t()]}
  def create(params) do
    @namespace |> API.create(params) |> handle_response()
  end

  @doc """
  Updates permission in Warrant
  Expects a map with the following keys:
    - name
    - description
  Example:
    WarrantEx.Permission.update("permission_1", %{name: "new_name", description: "new_description"})
  """
  @spec update(String.t(), map) :: {:error, any} | {:ok, t()}
  def update(permission_id, params) do
    @namespace |> API.update(permission_id, params) |> handle_response()
  end

  @doc """
    Delete a permission or list of permissions in Warrant
    Expects a permission_id or list of maps with the following key:
      - permissionId

    Example:
      WarrantEx.Permission.delete("permission_1")
      WarrantEx.Permission.delete([%{permissionId: "permission_1"}, %{permissionId: "permission_2"}])
  """

  @spec delete([map()] | String.t()) :: :ok
  def delete(params), do: API.delete(@namespace, params)

  @spec list_implied_permissions(String.t()) :: {:ok, [t()]} | {:error, any()}
  def list_implied_permissions(permission_id) do
    namespace = "#{@namespace}/#{permission_id}/permissions"
    namespace |> API.list(%{}) |> handle_response()
  end

  @spec add_implied_permission(String.t(), String.t()) :: {:ok, t()} | {:error, any()}
  def add_implied_permission(permission_id, implied_permission_id) do
    namespace = "#{@namespace}/#{permission_id}/permissions/#{implied_permission_id}"
    namespace |> API.create() |> handle_response()
  end

  @spec remove_implied_permission(String.t(), String.t()) :: :ok | {:error, any()}
  def remove_implied_permission(permission_id, implied_permission_id) do
    namespace = "#{@namespace}/#{permission_id}/permissions"
    API.delete(namespace, implied_permission_id)
  end

  @spec handle_response({:ok, map() | [map()]} | {:error, any()}) ::
          {:ok, t() | [t()]} | {:error, any()}
  def handle_response(response) do
    case response do
      {:ok, result} when is_list(result) ->
        {:ok, Enum.map(result, &new(&1["permissionId"], &1["name"], &1["description"]))}

      {:ok, result} ->
        {:ok, new(result["permissionId"], result["name"], result["description"])}

      _ ->
        response
    end
  end
end
