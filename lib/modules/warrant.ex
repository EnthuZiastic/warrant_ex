defmodule WarrantEx.Warrant do
  @moduledoc """
  Warrant is a library for interacting with the Warrant API.
  """
  alias __MODULE__
  alias WarrantEx.API
  alias WarrantEx.Warrant.Object

  @enforce_keys [:object, :subject, :relation]
  defstruct [:object, :subject, :relation, options: []]

  @type t() :: %Warrant{
          object: Object.t(),
          subject: Object.t(),
          relation: String.t(),
          options: keyword()
        }

  @type filter() :: %{
          object: Object.t(),
          subject: Object.t(),
          relation: String.t(),
          subjectRelation: String.t()
        }

  @namespace "/v1/warrants"

  @spec new(Object.object_type() | String.t(), String.t(), String.t(), map(), String.t() | nil) ::
          t()
  def new(object_type, object_id, relation, subject, policy \\ nil)

  def new(object_type, object_id, relation, subject, policy) when is_atom(object_type) do
    %Warrant{
      object: Object.new(object_type, object_id),
      subject: Object.new(subject["objectType"], subject["objectId"]),
      relation: relation,
      options: [policy: policy]
    }
  end

  def new(object_type, object_id, relation, subject, policy) when is_binary(object_type) do
    object_type |> String.to_existing_atom() |> new(object_id, relation, subject, policy)
  end

  @spec list(filter()) :: {:ok, [t()]} | {:error, any()}
  def list(params) when is_map(params) do
    params = Enum.reduce(params, params, &from_object/2)
    @namespace |> API.list(params) |> handle_response()
  end

  @spec create(map()) :: {:ok, t()} | {:error, any()}
  def create(params) do
    @namespace |> API.create(params) |> handle_response()
  end

  @spec delete(map()) :: :ok | {:error, any()}
  def delete(params) when is_map(params) do
    API.delete(@namespace, params)
  end

  @spec handle_response(any) :: {:ok, t()} | {:error, any()}
  def handle_response(response) do
    case response do
      {:ok, result} when is_list(result) ->
        {:ok,
         Enum.map(
           result,
           &new(&1["objectType"], &1["objectId"], &1["relation"], &1["subject"], &1["policy"])
         )}

      {:ok, result} ->
        {:ok,
         new(
           result["objectType"],
           result["objectId"],
           result["relation"],
           result["subject"],
           result["policy"]
         )}

      _ ->
        response
    end
  end

  defp from_object({:object, %Object{object_type: object_type, object_id: object_id}}, params) do
    params
    |> Map.put(:objectType, object_type)
    |> Map.put(:objectId, object_id)
    |> Map.delete(:object)
  end

  defp from_object({:subject, %Object{object_type: object_type, object_id: object_id}}, params) do
    params
    |> Map.put(:subjectType, object_type)
    |> Map.put(:subjectId, object_id)
    |> Map.delete(:subject)
  end

  defp from_object(_, params), do: params
end
