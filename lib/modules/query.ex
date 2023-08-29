defmodule WarrantEx.Query do
  @moduledoc false
  # alias WarrantEx.Warrant.Object
  defstruct [:select_clause, :for_clause, :where_clause]

  @type t() :: %__MODULE__{
          select_clause: String.t(),
          for_clause: String.t(),
          where_clause: list()
        }

  def select(query, select_clause) when is_list(select_clause) do
    select_clause = Enum.join(select_clause, ", ")
    select(query, select_clause)
  end

  def select(query, select_clause) when is_binary(select_clause) do
    Map.put(query, :select_clause, select_clause)
  end

  def select_explicit(query, select_clause) when is_list(select_clause) do
    select_clause = Enum.join(select_clause, ", ")
    select_explicit(query, select_clause)
  end

  def select_explicit(query, select_clause) when is_binary(select_clause) do
    Map.put(query, :select_clause, "explicit #{select_clause}")
  end
end
