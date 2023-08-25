defmodule WarrantEx.User do
  @moduledoc false
  alias __MODULE__
  alias WarrantEx.Request
  alias WarrantEx.TypeUtils

  defstruct [:user_id, :email, :created_at]

  @type t() :: %User{
          user_id: String.t(),
          email: String.t(),
          created_at: DateTime.t()
        }

  @doc """
  Create a new user struct
  Expects a unique user_id, and email and created_at
  """

  @spec new(String.t(), String.t(), String.t()) :: WarrantEx.User.t()
  def new(user_id, email, created_at) do
    {:ok, dt, _} = DateTime.from_iso8601(created_at)

    %User{
      user_id: user_id,
      email: email,
      created_at: dt
    }
  end

  @spec get(String.t()) :: User.t()
  def get(user_id) do
    response =
      Request.new()
      |> Request.with_method(:get)
      |> Request.with_path("/v1/users/#{user_id}")
      |> Request.send()

    case response do
      {:ok, result} ->
        {:ok, new(result["userId"], result["email"], result["createdAt"])}

      _ ->
        response
    end
  end

  @spec list(TypeUtils.list_filter()) :: [User.t()]
  def list(filter) do
    response =
      Request.new()
      |> Request.with_method(:get)
      |> Request.with_path("/v1/users")
      |> Request.with_params(filter)
      |> Request.send()

    case response do
      {:ok, result} ->
        {:ok, Enum.map(result, &new(&1["userId"], &1["email"], &1["createdAt"]))}

      _ ->
        response
    end
  end

  @doc """
    Create a user or list of users in Warrant
    Expects a map or list of maps with the following keys:
      - userId
      - email
  """
  @spec create(map() | [map()]) :: {:error, any} | {:ok, User.t() | [User.t()]}
  def create(params) do
    response =
      Request.new()
      |> Request.with_method(:post)
      |> Request.with_path("/v1/users")
      |> Request.with_body(params)
      |> Request.send()

    case response do
      {:ok, result} when is_list(result) ->
        {:ok, Enum.map(result, &new(&1["userId"], &1["email"], &1["createdAt"]))}

      {:ok, result} ->
        {:ok, new(result["userId"], result["email"], result["createdAt"])}

      _ ->
        response
    end
  end

  @doc """
  Updates user in Warrant
  Expects a map with the following key:
    - email
  Example:
    WarrantEx.User.update("user_1", %{email: "new_email"})
  """
  @spec update(String.t(), map) :: {:error, any} | {:ok, User.t()}
  def update(user_id, params) do
    response =
      Request.new()
      |> Request.with_method(:put)
      |> Request.with_path("/v1/users/#{user_id}")
      |> Request.with_body(params)
      |> Request.send()

    case response do
      {:ok, result} ->
        {:ok, new(result["userId"], result["email"], result["createdAt"])}

      _ ->
        response
    end
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
  def delete(params) when is_list(params) do
    response =
      Request.new()
      |> Request.with_method(:delete)
      |> Request.with_path("/v1/users")
      |> Request.with_body(params)
      |> Request.send()

    case response do
      {:ok, _} ->
        :ok

      _ ->
        response
    end
  end

  def delete(user_id) do
    response =
      Request.new()
      |> Request.with_method(:delete)
      |> Request.with_path("/v1/users/#{user_id}")
      |> Request.send()

    case response do
      {:ok, _} ->
        :ok

      _ ->
        response
    end
  end
end
