defmodule ExActivecampaign.Contact do
  @moduledoc """
    ActiveCampaign Contacts API.

    see: https://developers.activecampaign.com/reference#contact
  """

  @list_status_unconfirmed 0
  @list_status_active 1
  @list_status_unsubscribed 2
  @list_status_bounced 3

  alias ExActivecampaign.Api

  @doc """
    Creates a Contact on the ActiveCampaign system

    see: https://developers.activecampaign.com/reference#create-contact

    Expects a map in the following structure:
    ```
    %{
      email: "johndoe@example.com",
      first_name: "John",
      last_name: "Doe",
      phone: "7223224241"
    }
    ```

    ## Examples

      iex> ExActivecampaign.Contact.create(%{email: "johndoe@example.com", first_name: "John", last_name: "Doe", phone: "7223224241"})
      %{contact: %{email: "johndoe@example.com", firstName: "John", id: "1", lastName: "Doe", phone: "7223224241"}}

      iex> ExActivecampaign.Contact.create(%{email: "1234", first_name: "John", last_name: "Doe", phone: "7223224241"})
      %{error_message: "Unprocessable Entity"}

      iex> ExActivecampaign.Contact.create(%{email: "1234"})
      ** (FunctionClauseError) no function clause matching in ExActivecampaign.Contact.create/1
  """
  def create(
        %{email: _email, first_name: _first_name, last_name: _last_name, phone: _phone} = params
      ) do
    Api.post(Api.base_url() <> "/contacts", %{contact: params}, headers())
    |> handle_response
  end

  @doc """
    Creates or Updates a Contact on the ActiveCampaign system

    see: https://developers.activecampaign.com/reference#create-contact-sync

    Expects a map in the following structure:
    ```
    %{
      email: "johndoe@example.com",
      first_name: "John",
      last_name: "Doe",
      phone: "7223224241"
    }
    ```

    ## Examples

      iex> ExActivecampaign.Contact.create_or_update(%{email: "johndoe@example.com", first_name: "John", last_name: "Doe", phone: "7223224241"})
      %{contact: %{email: "johndoe@example.com", firstName: "John", id: "1", lastName: "Doe", phone: "7223224241"}}

      iex> ExActivecampaign.Contact.create_or_update(%{email: "1234", first_name: "John", last_name: "Doe", phone: "7223224241"})
      %{error_message: "Unprocessable Entity"}

      iex> ExActivecampaign.Contact.create_or_update(%{email: "1234"})
      ** (FunctionClauseError) no function clause matching in ExActivecampaign.Contact.create_or_update/1
  """
  def create_or_update(
        %{email: _email, first_name: _first_name, last_name: _last_name, phone: _phone} = params
      ) do
    Api.post(Api.base_url() <> "/contact/sync", %{contact: params}, headers())
    |> handle_response
  end

  @doc """
    Retrieves a Contact from the ActiveCampaign system by their ID within the ActiveCampaign system

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

  @doc """
    Subscribe a contact to a list or unsubscribe a contact from a list

    Expects a map in the following structure:
    ```
    %{
      contact: 1,
      list: 1,
      status: 1
    }
    ```

    ## Examples

      iex> ExActivecampaign.Contact.update_list_status(%{contact: 1, list: 1, status: 1})
      %{contactList: %{contact: "1", list: "1", status: 1}, contacts: [%{email: "johndoe@example.com", firstName: "John", id: "1", lastName: "Doe", phone: "7223224241"}]}

      iex> ExActivecampaign.Contact.update_list_status(%{contact: 1, list: 1, status: 0})
      %{contactList: %{contact: "1", list: "1", status: 0}, contacts: [%{email: "johndoe@example.com", firstName: "John", id: "1", lastName: "Doe", phone: "7223224241"}]}

      iex> ExActivecampaign.Contact.update_list_status(%{contact: "invalid-contact", list: 1, status: 1})
      %{error_message: "Bad Request"}

      iex> ExActivecampaign.Contact.update_list_status(%{contact: 1, list: "invalid-list", status: 1})
      %{error_message: "Bad Request"}

      iex> ExActivecampaign.Contact.update_list_status(%{contact: 1, list: 1, status: "invalid-status"})
      %{error_message: "Status must be one of: 0 (unconfirmed), 1 (active), 2 (unsubscribed), 3 (active)"}
  """
  def update_list_status(%{contact: _contact, list: _list, status: status} = params)
      when status in [
             @list_status_unconfirmed,
             @list_status_active,
             @list_status_unsubscribed,
             @list_status_bounced
           ] do
    Api.post(Api.base_url() <> "/contactLists", %{contactList: params}, headers())
    |> handle_response
  end
  def update_list_status(_) do
    %{error_message: "Status must be one of: 0 (unconfirmed), 1 (active), 2 (unsubscribed), 3 (active)"}
  end

  defp handle_response({status, body}) do
    case status do
      200 -> body
      201 -> body
      400 -> %{error_message: "Bad Request"}
      403 -> %{error_message: "Forbidden"}
      404 -> %{error_message: "Not Found"}
      422 -> %{error_message: "Unprocessable Entity"}
      500 -> %{error_message: "Internal Server Error"}
    end
  end

  defp headers(), do: []
end
