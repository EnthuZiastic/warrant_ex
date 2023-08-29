defmodule WarrantEx.Role do
  @moduledoc false
  alias __MODULE__
  alias WarrantEx.API
  alias WarrantEx.Permission
  alias WarrantEx.TypeUtils
  alias WarrantEx.Warrant

  @enforce_keys [:role_id, :name]
  defstruct [:role_id, :name, :description]

  @type t() :: %Role{
          role_id: String.t(),
          name: String.t(),
          description: String.t()
        }

  @namespace "/v1/roles"

  @doc """
  Create a new role struct
  Expects a unique role_id, and name and description
  """

  @spec new(String.t(), String.t(), String.t()) :: t()
  def new(role_id, name, description) do
    %Role{
      role_id: role_id,
      name: name,
      description: description
    }
  end

  @spec get(String.t()) :: {:ok, t()} | {:error, any()}
  def get(role_id) do
    @namespace |> API.get(role_id) |> handle_response()
  end

  @spec list(TypeUtils.list_filter()) :: {:ok, [t()]} | {:error, any()}
  def list(filter) do
    @namespace |> API.list(filter) |> handle_response()
  end

  @doc """
    Create a role or list of roles in Warrant
    Expects a map or list of maps with the following keys:
      - roleId
      - name
      - description
  """
  @spec create(map() | [map()]) :: {:error, any} | {:ok, t() | [t()]}
  def create(params) do
    @namespace |> API.create(params) |> handle_response()
  end

  @doc """
  Updates role in Warrant
  Expects a map with the following keys:
    - name
    - description
  Example:
    WarrantEx.Role.update("role_1", %{name: "new_name", description: "new_description"})
  """
  @spec update(String.t(), map) :: {:error, any} | {:ok, t()}
  def update(role_id, params) do
    @namespace |> API.update(role_id, params) |> handle_response()
  end

  @doc """
    Delete a role or list of roles in Warrant
    Expects a role_id or list of maps with the following key:
      - roleId

    Example:
      WarrantEx.Role.delete("role_1")
      WarrantEx.Role.delete([%{roleId: "role_1"}, %{roleId: "role_2"}])
  """

  @spec delete([map()] | String.t()) :: :ok
  def delete(params), do: API.delete(@namespace, params)

  @spec assign_permission(String.t(), String.t()) :: {:ok, Warrant.t()} | {:error, any()}
  def assign_permission(role_id, permission_id) do
    namespace = "#{@namespace}/#{role_id}/permissions/#{permission_id}"
    namespace |> API.create() |> Warrant.handle_response()
  end

  @spec remove_permission(String.t(), String.t()) :: :ok | {:error, any()}
  def remove_permission(role_id, permission_id) do
    namespace = "#{@namespace}/#{role_id}/permissions"
    API.delete(namespace, permission_id)
  end

  @spec list_permissions(String.t(), TypeUtils.list_filter() | map()) ::
          {:ok, [Permission.t()]} | {:error, any()}
  def list_permissions(role_id, filter) do
    namespace = "#{@namespace}/#{role_id}/permissions"
    namespace |> API.list(filter) |> Permission.handle_response()
  end

  @spec list_implied_roles(String.t()) :: {:ok, [t()]} | {:error, any()}
  def list_implied_roles(role_id) do
    namespace = "#{@namespace}/#{role_id}/roles"
    namespace |> API.list(%{}) |> handle_response()
  end

  @spec add_implied_role(String.t(), String.t()) :: {:ok, Warrant.t()} | {:error, any()}
  def add_implied_role(role_id, implied_role_id) do
    namespace = "#{@namespace}/#{role_id}/roles/#{implied_role_id}"
    namespace |> API.create() |> handle_response()
  end

  @spec remove_implied_role(String.t(), String.t()) :: :ok | {:error, any()}
  def remove_implied_role(role_id, implied_role_id) do
    namespace = "#{@namespace}/#{role_id}/roles"
    API.delete(namespace, implied_role_id)
  end

  @spec handle_response({:ok, map() | [map()]} | {:error, any()}) ::
          {:ok, t() | [t()]} | {:error, any()}
  def handle_response(response) do
    case response do
      {:ok, result} when is_list(result) ->
        {:ok, Enum.map(result, &new(&1["roleId"], &1["name"], &1["description"]))}

      {:ok, result} ->
        {:ok, new(result["roleId"], result["name"], result["description"])}

      _ ->
        response
    end
  end
end
