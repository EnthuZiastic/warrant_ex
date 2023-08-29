defmodule WarrantEx.WarrantTest do
  use ExUnit.Case, async: true
  alias WarrantEx.Warrant
  alias WarrantEx.Warrant.Object

  describe "new/4" do
    test "it returns warrant object for valid args" do
      assert %Warrant{} =
               warrant =
               Warrant.new("tenant", "tenant_1", "owns", %{
                 "objectType" => "user",
                 "objectId" => "user_1"
               })

      assert %Object{} = warrant.object
      assert warrant.object.object_type == :tenant
      assert warrant.object.object_id == "tenant_1"
      assert warrant.relation == "owns"
      assert %Object{} = warrant.subject
      assert warrant.subject.object_type == :user
      assert warrant.subject.object_id == "user_1"
      assert warrant.policy == nil
    end
  end
end
