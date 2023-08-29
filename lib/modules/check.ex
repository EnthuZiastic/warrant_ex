defmodule WarrantEx.Check do
  @moduledoc false

  alias WarrantEx.Config
  alias WarrantEx.Request
  alias WarrantEx.Warrant
  alias WarrantEx.Warrant.Object

  @type op() :: :allOf | :anyOf

  @namespace "/v2/authorize"
  @endpoint_key :authorize_endpoint

  @spec check(Warrant.t(), keyword()) :: boolean()
  def check(warrant, options) do
    warrant = from_warrant(warrant)
    params = %{warrants: [warrant], debug: options[:debug]}
    is_authorized?(params)
  end

  @spec check_many(op(), [Warrant.t()], keyword()) :: boolean()
  def check_many(op, warrants, options) do
    warrants = Enum.map(warrants, &from_warrant/1)
    params = %{warrants: warrants, debug: options[:debug], op: op}
    is_authorized?(params)
  end

  @spec is_authorized?(map()) :: boolean()
  def is_authorized?(params) do
    case Config.get_config(@endpoint_key) do
      nil -> authorize?(params)
      endpoint -> edge_authorize?(params, endpoint)
    end
  end

  @spec authorize?(map()) :: boolean()
  def authorize?(params), do: handle_authorize(params, nil)

  @spec edge_authorize?(map(), String.t()) :: boolean()
  def edge_authorize?(params, endpoint), do: handle_authorize(params, endpoint)

  defp handle_authorize(params, endpoint) do
    request =
      Request.new()
      |> Request.with_method(:post)
      |> Request.with_path(@namespace)
      |> Request.with_body(params)

    request =
      case endpoint do
        nil -> request
        endpoint -> Request.with_base_url(request, endpoint)
      end

    case Request.send(request) do
      {:ok, "Authorized"} -> true
      {:ok, "Not Authorized"} -> false
      response -> raise "Unexpected response while authorization check: #{inspect(response)}"
    end
  end

  defp from_warrant(%Warrant{
         object: %Object{object_type: object_type, object_id: object_id},
         subject: %Object{object_type: subject_type, object_id: subject_id},
         relation: relation,
         options: warrant_options
       }) do
    %{
      object_type: object_type,
      object_id: object_id,
      subject_type: subject_type,
      subject_id: subject_id,
      relation: relation,
      context: warrant_options[:context]
    }
  end
end
