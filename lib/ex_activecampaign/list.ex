defmodule ExActivecampaign.List do
  @moduledoc """
    ActiveCampaign List API.

    see: https://developers.activecampaign.com/reference#lists
  """

  alias ExActivecampaign
  alias ExActivecampaign.ApiV3

  @doc """
    Retrieves a List from the ActiveCampaign system by their Id or stringId within the ActiveCampaign system

    ## Examples

      iex> ExActivecampaign.List.retrieve(1)
      %{list: %{stringid: "example-list", name: "Example List", id: "1"}}

      iex> ExActivecampaign.List.retrieve("some-invalid-list-id")
      %{error_message: "Not Found"}
  """
  def retrieve(id) do
    ApiV3.get(ExActivecampaign.base_url_v3() <> "/lists/#{id}", %{}, [])
    |> ApiV3.handle_response()
  end
end
