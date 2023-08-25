defmodule WarrantEx.User do
  @moduledoc false
  alias __MODULE__
  alias WarrantEx.API
  alias WarrantEx.TypeUtils

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
  def delete(params) when is_list(params), do: API.delete(@namespace, params)

  defp handle_response(response) do
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
