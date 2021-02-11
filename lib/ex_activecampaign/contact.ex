defmodule ExActivecampaign.Contact do
  @moduledoc """
    ActiveCampaign Contacts API.

    see: https://developers.activecampaign.com/reference#contact
  """

  @list_status_unconfirmed 0
  @list_status_active 1
  @list_status_unsubscribed 2
  @list_status_bounced 3

  alias ExActivecampaign.{ApiV1, ApiV3}

  @doc """
    Creates a Contact on the ActiveCampaign system

    see: https://developers.activecampaign.com/reference#create-contact

    Expects a map in the following structure:
    ```
    %{
      "email" => "johndoe@example.com",
      "first_name" => "John",
      "last_name" => "Doe",
      "phone" => "7223224241"
    }
    ```

    ## Examples

      iex> ExActivecampaign.Contact.create(%{"email" => "johndoe@example.com", "first_name" => "John", "last_name" => "Doe", "phone" => "7223224241"})
      %{contact: %{email: "johndoe@example.com", firstName: "John", id: "1", lastName: "Doe", phone: "7223224241"}}

      iex> ExActivecampaign.Contact.create(%{"email" => "1234", "first_name" => "John", "last_name" => "Doe", "phone" => "7223224241"})
      %{error_message: "Bad Request", errors: [%{"title": "Contact Email Address is not valid.", "detail": "", "code": "email_invalid", "error": "must_be_valid_email_address", "source": %{"pointer": "/data/attributes/email"}}]}

      iex> ExActivecampaign.Contact.create(%{"phone" => "1234"})
      ** (FunctionClauseError) no function clause matching in ExActivecampaign.Contact.create/1
  """
  def create(%{"email" => _email} = params) do
    ApiV3.post(ExActivecampaign.base_url_v3() <> "/contacts", %{contact: params})
    |> ApiV3.handle_response()
  end

  @doc """
    Creates or Updates a Contact on the ActiveCampaign system

    see: https://developers.activecampaign.com/reference#create-contact-sync

    Expects a map in the following structure:
    ```
    %{
      "email" => "johndoe@example.com",
      "first_name" => "John",
      "last_name" => "Doe",
      "phone" => "7223224241"
    }
    ```

    ## Examples

      iex> ExActivecampaign.Contact.create_or_update(%{"email" => "johndoe@example.com", "first_name" => "John", "last_name" => "Doe", "phone" => "7223224241"})
      %{contact: %{email: "johndoe@example.com", firstName: "John", id: "1", lastName: "Doe", phone: "7223224241"}}

      iex> ExActivecampaign.Contact.create_or_update(%{"email" => "1234", "first_name" => "John", "last_name" => "Doe", "phone" => "7223224241"})
      %{error_message: "Bad Request", errors: [%{"title": "Contact Email Address is not valid.", "detail": "", "code": "email_invalid", "error": "must_be_valid_email_address", "source": %{"pointer": "/data/attributes/email"}}]}

      iex> ExActivecampaign.Contact.create_or_update(%{"phone" => "1234"})
      ** (FunctionClauseError) no function clause matching in ExActivecampaign.Contact.create_or_update/1
  """
  def create_or_update(%{"email" => _email} = params) do
    ApiV3.post(ExActivecampaign.base_url_v3() <> "/contact/sync", %{contact: params})
    |> ApiV3.handle_response()
  end

  @doc """
  Updates an existing Contact on the ActiveCampaign system

    see: https://developers.activecampaign.com/reference#update-a-contact-new

    Expects an ActiveCampaign Contact ID (returned from initial Contact creation and stored in User table) as well as
    a map of properties to update, such as:
    ```
    %{
      "email" => "johndoe@example.com",
      "first_name" => "John",
      "last_name" => "Doe",
      "phone" => "7223224241"
    }
    ```

    ## Examples

      iex> ExActivecampaign.Contact.update(80480, %{"email" => "johndoe@example.com", "first_name" => "John", "last_name" => "Doe", "phone" => "7223224241"})
      %{contact: %{email: "johndoe@example.com", firstName: "John", id: "80480", lastName: "Doe", phone: "7223224241"}}

      iex> ExActivecampaign.Contact.update(80480, %{"email" => "1234", "first_name" => "John", "last_name" => "Doe", "phone" => "7223224241"})
      %{error_message: "Bad Request", errors: [%{"title": "Contact Email Address is not valid.", "detail": "", "code": "email_invalid", "error": "must_be_valid_email_address", "source": %{"pointer": "/data/attributes/email"}}]}
  """
  def update(contact_id, params) do
    ApiV3.post(
      ExActivecampaign.base_url_v3() <> "/contacts/" <> Integer.to_string(contact_id),
      params
    )
    |> ApiV3.handle_response()
  end

  @doc """
  Adds the Tag identified by tag_id to the Contact identified by contact_id.

    ## Examples

      iex> ExActivecampaign.Contact.tags(80480, 167)
      %{contactTag: %{cdate: "2020-09-01T17:25:00-00:00", contact: "80480", id: "1", links: %{contact: "/80480/contact", tag: "/167/tag"}, tag: "167"}}
  """
  def tags(contact_id, tag_id) do
    ApiV3.post(ExActivecampaign.base_url_v3() <> "/contactTags", %{
      "contactTag" => %{
        "contact" => "#{contact_id}",
        "tag" => "#{tag_id}"
      }
    })
    |> ApiV3.handle_response()
  end

  @doc """
    Uses v1 of the API to sync a Contact on the ActiveCampaign system, including bulk update of custom field values

    see: https://www.activecampaign.com/api/example.php?call=contact_sync

    Expects a map in the following structure:
    ```
    %{
      "email" => "johndoe@example.com",
      "first_name" => "John",
      "last_name" => "Doe",
      "phone" => "7223224241"
    }
    ```

    ## Examples

      iex> ExActivecampaign.Contact.contact_sync(%{"email" => "johndoe@example.com", "first_name" => "John", "last_name" => "Doe", "phone" => "7223224241"})
      %{"subscriber_id" => 1, "sendlast_should" => 0, "sendlast_did" => 0, "result_code" => 1, "result_message" => "Contact added", "result_output" => "json"}
  """
  def contact_sync(%{"email" => _email} = params) do
    ApiV1.post(
      ExActivecampaign.base_url_v1(),
      params,
      %{
        api_key: Application.get_env(:ex_activecampaign, :api_token),
        api_action: "contact_sync",
        api_output: "json"
      }
    )
    |> ApiV1.handle_response()
  end

  @doc """
    Retrieves a Contact from the ActiveCampaign system by their ID within the ActiveCampaign system

    ## Examples

      iex> ExActivecampaign.Contact.retrieve(1)
      %{contact: %{id: "1", email: "johndoe@example.com", firstName: "John", lastName: "Doe", phone: "7223224241"}, contactLists: []}

      iex> ExActivecampaign.Contact.retrieve(101)
      %{error_message: "Bad Request", errors: [%{code: "related_missing", detail: "", error: "contact_not_exist", source: %{pointer: "/data/attributes/contact"}, title: "The related contact does not exist."}]}

      iex> ExActivecampaign.Contact.retrieve("johndoe@example.com")
      %{contact: %{id: "1", email: "johndoe@example.com", firstName: "John", lastName: "Doe", phone: "7223224241"}, contactLists: []}

      iex> ExActivecampaign.Contact.retrieve("some-invalid-email")
      %{error_message: "Bad Request", errors: [%{code: "related_missing", detail: "", error: "contact_not_exist", source: %{pointer: "/data/attributes/contact"}, title: "The related contact does not exist."}]}
  """
  def retrieve(id) when is_integer(id) do
    ApiV3.get(ExActivecampaign.base_url_v3() <> "/contacts/#{id}", %{}, [])
    |> ApiV3.handle_response()
  end

  def retrieve(email) when is_binary(email) do
    ApiV3.get(ExActivecampaign.base_url_v3() <> "/contacts?email=#{email}", %{}, [])
    |> ApiV3.handle_response()
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
      %{error_message: "Bad Request", errors: [%{code: "related_missing", detail: "", error: "contact_not_exist", source: %{pointer: "/data/attributes/contact"}, title: "The related contact does not exist."}]}

      iex> ExActivecampaign.Contact.update_list_status(%{contact: 1, list: "invalid-list", status: 1})
      %{error_message: "Bad Request", errors: [%{title: "The related list does not exist.", detail: "", code: "related_missing", error: "list_not_exist", source: %{pointer: "/data/attributes/list"}}]}

      iex> ExActivecampaign.Contact.update_list_status(%{contact: "invalid-contact", list: "invalid-list", status: 1})
      %{error_message: "Bad Request", errors: [%{title: "The related list does not exist.", detail: "", code: "related_missing", error: "list_not_exist", source: %{pointer: "/data/attributes/list"}}, %{title: "The related contact does not exist.", detail: "", code: "related_missing", error: "contact_not_exist", source: %{pointer: "/data/attributes/contact"}}]}

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
    ApiV3.post(ExActivecampaign.base_url_v3() <> "/contactLists", %{contactList: params})
    |> ApiV3.handle_response()
  end

  def update_list_status(_) do
    %{
      error_message:
        "Status must be one of: 0 (unconfirmed), 1 (active), 2 (unsubscribed), 3 (active)"
    }
  end
end
