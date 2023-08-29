defmodule WarrantEx.Config do
  @moduledoc """
  Config for warrant defined in the app level
  """
  alias __MODULE__

  @default_base_url "https://api.warrant.dev"

  @enforce_keys [:base_url, :api_key]
  defstruct base_url: @default_base_url,
            api_key: @type(t() :: %Config{base_url: String.t(), api_key: String.t()}),
            authorize_endpoint: nil

  @spec get_config :: Config.t()
  def get_config do
    case Application.get_all_env(:warrant) do
      [] ->
        raise ArgumentError, message: "Environment variables for warrant is not defined"

      config ->
        struct!(Config, config)
    end
  end

  @spec get_config(atom()) :: String.t() | nil
  def get_config(key) when is_atom(key) do
    get_config() |> Map.get(key) |> get_value()
  end

  def get_config(key),
    do: raise(ArgumentError, message: "#{Config} expected key `#{key}` to be an atom")

  defp get_value({:system, system_var}), do: System.get_env(system_var)

  defp get_value(value), do: value
end
