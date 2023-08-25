defmodule WarrantEx.TypeUtils do
  @moduledoc false
  @type list_filter() :: %{
          beforeId: String.t(),
          beforeValue: String.t(),
          afterId: String.t(),
          afterValue: String.t(),
          sortBy: String.t(),
          sortOrder: String.t(),
          page: non_neg_integer(),
          limit: non_neg_integer()
        }
end
