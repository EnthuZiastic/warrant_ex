defmodule WarrantEx.Warrant do
  @moduledoc """
  Warrant is a library for interacting with the Warrant API.
  """
  alias __MODULE__
  alias __MODULE__.Subject

  @enforce_keys [:object_type, :object_id, :relation, :subject]
  defstruct [:object_type, :object_id, :relation, :subject, :policy]

  @type object_type() :: :tenant | :user
  @type t() :: %Warrant{
          object_type: object_type(),
          object_id: String.t(),
          relation: String.t(),
          subject: Subject.t(),
          policy: String.t() | nil
        }

  @spec new(object_type(), String.t(), String.t(), map(), String.t() | nil) :: t()
  def new(object_type, object_id, relation, subject, policy \\ nil) do
    %Warrant{
      object_type: object_type,
      object_id: object_id,
      relation: relation,
      subject: Subject.new(subject["objectType"], subject["objectId"]),
      policy: policy
    }
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
end

defmodule WarrantEx.Warrant.Subject do
  @moduledoc false
  alias __MODULE__

  @enforce_keys [:object_type, :object_id]
  defstruct [:object_type, :object_id]

  @type t() :: %Subject{
          object_type: WarrantEx.Warrant.object_type(),
          object_id: String.t()
        }

  @spec new(WarrantEx.Warrant.object_type(), String.t()) :: t()
  def new(object_type, object_id) do
    %Subject{
      object_type: object_type,
      object_id: object_id
    }
  end
end
