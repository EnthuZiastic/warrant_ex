defmodule WarrantEx.UserTest do
  use ExUnit.Case
  import Mock

  alias WarrantEx.Config
  alias WarrantEx.User
  @default_base_url "https://api.warrant.dev"
  @default_api_key "api_test_52sML3sUtpAI5W06tKb7eDgUd-1nCLdYOKFLlOK22xo="
  describe "create_user/1" do
    test "it creates user for valid params" do
      with_mocks([
        {Config, [],
         get_config: fn -> %{api_key: @default_api_key, base_url: @default_base_url} end}
        # {HTTPoison, [],
        #  request: fn _, _, body, _ ->
        #    {:ok,
        #     %HTTPoison.Response{
        #       body:
        #         body
        #         |> Jason.decode!()
        #         |> Map.put("createdAt", "2023-08-25T04:32:37.283245Z")
        #         |> Jason.encode!(),
        #       status_code: 200
        #     }}
        #  end}
      ]) do
        # params = [
        #   %{
        #     userId: "user_3",
        #     email: "email@email.email"
        #   },
        #   %{
        #     userId: "user_4",
        #     email: "email_2@email.email"
        #   }
        # ]

        assert {:ok, %User{} = user} =
                 User.list(%{limit: 1})
                 |> IO.inspect()

        assert user.user_id == "user_1"
        assert user.email == "email@email.email"
        assert user.created_at == ~U[2023-08-25 04:32:37.283245Z]
      end
    end
  end
end
