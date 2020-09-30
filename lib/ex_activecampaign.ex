defmodule ExActivecampaign do
  @moduledoc """
  ExActivecampaign is an API client for the ActiveCampaign API.
  """

  @default_base_url_v1 "http://localhost:8081/v1"
  @default_base_url_v3 "http://localhost:8081/v3"
  @default_api_token "DEFAULT-ACTIVECAMPAIGN-TOKEN"

  def api_token() do
    Application.get_env(:ex_activecampaign, :api_token)
    |> case do
      {:system, lookup} -> System.get_env(lookup)
      nil -> @default_api_token
      token -> token
    end
  end

  @doc """
  The service's default URL for API v1 requests, it will lookup the config,
  possibly check the env variables and default if still not found

  ## Examples

      iex> ExActivecampaign.base_url_v1()
      "http://localhost:8081/v1"
  """
  def base_url_v1() do
    Application.get_env(:ex_activecampaign, :base_url_v1)
    |> case do
      {:system, lookup} -> System.get_env(lookup)
      nil -> @default_base_url_v1
      url -> url
    end
  end

  @doc """
  The service's default URL for API v3 requests, it will lookup the config,
  possibly check the env variables and default if still not found

  ## Examples

      iex> ExActivecampaign.base_url_v3()
      "http://localhost:8081/v3"
  """
  def base_url_v3() do
    Application.get_env(:ex_activecampaign, :base_url_v3)
    |> case do
      {:system, lookup} -> System.get_env(lookup)
      nil -> @default_base_url_v3
      url -> url
    end
  end
end
