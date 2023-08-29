defmodule WarrantEx.Warrant.Object do
  @moduledoc false
  alias __MODULE__

  @enforce_keys [:object_type, :object_id]
  defstruct [:object_type, :object_id]

  @object_types [:feature, :permission, :pricingTier, :role, :tenant, :user]
  @type object_type() :: :feature | :permission | :pricingTier | :role | :tenant | :user

  @type t() :: %Object{
          object_type: object_type(),
          object_id: String.t()
        }

  @spec new(object_type() | String.t(), String.t()) :: t()
  def new(object_type, object_id) when object_type in @object_types do
    %Object{
      object_type: object_type,
      object_id: object_id
    }
  end

  def new(object_type, object_id) when is_binary(object_type) do
    object_type |> String.to_existing_atom() |> new(object_id)
  end
end
