defmodule ExActivecampaign.Contact do
  @moduledoc """
    ActiveCampaign Contacts API.

    see: https://developers.activecampaign.com/reference#contact
  """

  alias ExActivecampaign.Api

  @doc """
    Creates a Contact on the ActiveCampaign system

    ## Examples

      iex> ExActivecampaign.Contact.create(%{contact: %{email: "johndoe@example.com", firstName: "John", lastName: "Doe", phone: "7223224241"}})
      %{contact: %{email: "johndoe@example.com", firstName: "John", id: 1, lastName: "Doe", phone: "7223224241"}}

      iex> ExActivecampaign.Contact.create(%{contact: %{email: "1234"}})
      %{error_message: "Unprocessable Entity"}
  """
  def create(params) do
    Api.post(Api.base_url() <> "/contacts", params, headers())
    |> handle_response
  end

  def create_or_update(params) do
    Api.post(Api.base_url() <> "/contact/sync", params, headers())
    |> handle_response
  end

  @doc """
    Retrieves a Contact from the ActiveCampaign system

    ## Examples

      iex> ExActivecampaign.Contact.retrieve(1)
      %{contact: %{id: "1", email: "johndoe@example.com", firstName: "John", lastName: "Doe", phone: "7223224241"}, contactLists: []}

      iex> ExActivecampaign.Contact.retrieve("some-invalid-id")
      %{error_message: "Not Found"}
  """
  def retrieve(id) do
    Api.get(Api.base_url() <> "/contacts/#{id}", %{}, headers())
    |> handle_response
  end

  def update_list_status(params) do
    Api.get(Api.base_url() <> "/contactLists", params, headers())
    |> handle_response
  end

  defp handle_response({status, body}) do
    case status do
      200 -> body
      201 -> body
      403 -> %{error_message: "Forbidden"}
      404 -> %{error_message: "Not Found"}
      422 -> %{error_message: "Unprocessable Entity"}
      500 -> %{error_message: "Internal Server Error"}
    end
  end

  defp headers(), do: []
end
