defmodule ExActivecampaign.MockServer do
  @moduledoc """
    A mock ActiveCampaign API server against which to run tests
  """

  use Plug.Router

  plug(Plug.Parsers,
    parsers: [:json, :urlencoded],
    pass: ["text/*"],
    json_decoder: Poison
  )

  plug(:match)
  plug(:dispatch)

  defp post_success_created(conn, body) do
    conn
    |> Plug.Conn.send_resp(201, Poison.encode!(body))
  end

  defp post_failure_bad_request(conn) do
    conn
    |> Plug.Conn.send_resp(400, Poison.encode!(%{message: "Bad Request"}))
  end

  get "/v3/contacts" do
    case conn.params do
      %{"email" => "johndoe@example.com"} -> contacts_get_success(conn)
      %{"email" => "some-invalid-email"} -> get_failure_contact_not_found(conn)
    end
  end

  get "/v3/contacts/:id" do
    case conn.path_params do
      %{"id" => "1"} -> contacts_get_success(conn)
      %{"id" => "101"} -> get_failure_contact_not_found(conn)
    end
  end

  defp contacts_get_success(conn) do
    conn
    |> Plug.Conn.send_resp(
      200,
      Poison.encode!(%{
        contact: %{
          id: "1",
          email: "johndoe@example.com",
          firstName: "John",
          lastName: "Doe",
          phone: "7223224241"
        },
        contactLists: []
      })
    )
  end

  defp get_failure_contact_not_found(conn) do
    conn
    |> Plug.Conn.send_resp(
         404,
         Poison.encode!(%{
           errors: [
             %{
               title: "The related contact does not exist.",
               detail: "",
               code: "related_missing",
               error: "contact_not_exist",
               source: %{
                 pointer: "/data/attributes/contact"
               }
             }
           ]
         })
       )
  end

  post "/v3/contacts" do
    case conn.params do
      %{"contact" => %{"email" => "johndoe@example.com"}} ->
        post_success_created(conn, %{
          "contact" => %{
            "id" => "1",
            "email" => "johndoe@example.com",
            "firstName" => "John",
            "lastName" => "Doe",
            "phone" => "7223224241"
          }
        })

      %{"contact" => %{"email" => "1234"}} ->
        post_failure_email_address_invalid(conn)
    end
  end

  defp post_failure_email_address_invalid(conn) do
    conn
    |> Plug.Conn.send_resp(400, Poison.encode!(%{
      errors: [
        %{
          title: "Contact Email Address is not valid.",
          detail: "",
          code: "email_invalid",
          error: "must_be_valid_email_address",
          source: %{
            pointer: "/data/attributes/email"
          }
        }
      ]
    }))
  end

  post "/v3/contact/sync" do
    case conn.params do
      %{"contact" => %{"email" => "johndoe@example.com"}} ->
        post_success_created(conn, %{
          "contact" => %{
            "id" => "1",
            "email" => "johndoe@example.com",
            "firstName" => "John",
            "lastName" => "Doe",
            "phone" => "7223224241"
          }
        })

      %{"contact" => %{"email" => "1234"}} ->
        post_failure_email_address_invalid(conn)
    end
  end

  post "/v3/contacts/80480" do
    case conn.params do
      %{"email" => "johndoe@example.com"} ->
        post_success_created(conn, %{
          "contact" => %{
            "id" => "80480",
            "email" => "johndoe@example.com",
            "firstName" => "John",
            "lastName" => "Doe",
            "phone" => "7223224241"
          }
        })

      %{"email" => "1234"} ->
        post_failure_email_address_invalid(conn)
    end
  end

  post "/v3/contactTags" do
    case conn.params do
      %{"contactTag" => %{"contact" => "80480", "tag" => "167"}} ->
        post_success_created(conn, %{
          "contactTag" => %{
            "cdate" => "2020-09-01T17:25:00-00:00",
            "contact" => "80480",
            "id" => "1",
            "links" => %{
              "contact" => "/80480/contact",
              "tag" => "/167/tag"
            },
            "tag" => "167"
          }
        })
    end
  end

  post "/v3/contactLists" do
    case conn.params do
      %{"contactList" => %{"list" => 1, "contact" => 1, "status" => 1}} ->
        post_success_created(conn, %{
          "contacts" => [
            %{
              "id" => "1",
              "email" => "johndoe@example.com",
              "firstName" => "John",
              "lastName" => "Doe",
              "phone" => "7223224241"
            }
          ],
          "contactList" => %{
            "contact" => "1",
            "list" => "1",
            "status" => 1
          }
        })

      %{"contactList" => %{"list" => 1, "contact" => 1, "status" => 0}} ->
        post_success_created(conn, %{
          "contacts" => [
            %{
              "id" => "1",
              "email" => "johndoe@example.com",
              "firstName" => "John",
              "lastName" => "Doe",
              "phone" => "7223224241"
            }
          ],
          "contactList" => %{
            "contact" => "1",
            "list" => "1",
            "status" => 0
          }
        })

      %{"contactList" => %{"list" => "invalid-list", "contact" => 1, "status" => 1}} ->
        post_failure_bad_request_invalid_list(conn)

      %{"contactList" => %{"list" => 1, "contact" => "invalid-contact", "status" => 1}} ->
        post_failure_bad_request_invalid_contact(conn)

      %{"contactList" => %{"list" => "invalid-list", "contact" => "invalid-contact", "status" => 1}} ->
        post_failure_bad_request_invalid_list_and_contact(conn)

      %{"contactList" => %{"list" => 1, "contact" => 1, "status" => "invalid-status"}} ->
        post_failure_bad_request(conn)
    end
  end

  defp post_failure_bad_request_invalid_list(conn) do
    conn
    |> Plug.Conn.send_resp(400, Poison.encode!(%{
      errors: [
        %{
          title: "The related list does not exist.",
          detail: "",
          code: "related_missing",
          error: "list_not_exist",
          source: %{
            pointer: "/data/attributes/list"
          }
        }
      ]
    }))
  end

  defp post_failure_bad_request_invalid_contact(conn) do
    conn
    |> Plug.Conn.send_resp(400, Poison.encode!(%{
      errors: [
        %{
          title: "The related contact does not exist.",
          detail: "",
          code: "related_missing",
          error: "contact_not_exist",
          source: %{
            pointer: "/data/attributes/contact"
          }
        }
      ]
    }))
  end

  defp post_failure_bad_request_invalid_list_and_contact(conn) do
    conn
    |> Plug.Conn.send_resp(400, Poison.encode!(%{
      errors: [
        %{
          title: "The related list does not exist.",
          detail: "",
          code: "related_missing",
          error: "list_not_exist",
          source: %{
            pointer: "/data/attributes/list"
          }
        },
        %{
          title: "The related contact does not exist.",
          detail: "",
          code: "related_missing",
          error: "contact_not_exist",
          source: %{
            pointer: "/data/attributes/contact"
          }
        }
      ]
    }))
  end

  get "/v3/lists/:id" do
    case conn.path_params do
      %{"id" => "1"} -> list_get_success(conn)
      %{"id" => "some-invalid-list-id"} -> get_failure_list_not_found(conn)
    end
  end

  defp list_get_success(conn) do
    conn
    |> Plug.Conn.send_resp(
      200,
      Poison.encode!(%{
        list: %{
          stringid: "example-list",
          name: "Example List",
          id: "1"
        }
      })
    )
  end

  defp get_failure_list_not_found(conn) do
    conn
    |> Plug.Conn.send_resp(
         404,
         Poison.encode!(%{
           errors: [
             %{
               title: "The related list does not exist.",
               detail: "",
               code: "related_missing",
               error: "list_not_exist",
               source: %{
                 pointer: "/data/attributes/list"
               }
             }
           ]
         })
       )
  end

  post "/v1" do
    case conn.query_params do
      %{"api_action" => "contact_sync", "api_output" => "json"} -> v1_post_contact_sync_json(conn)
    end
  end

  def v1_post_contact_sync_json(conn) do
    case conn.body_params do
      %{
        "email" => "johndoe@example.com",
        "first_name" => "John",
        "last_name" => "Doe",
        "phone" => "7223224241"
      } ->
        conn
        |> Plug.Conn.send_resp(
          200,
          Poison.encode!(%{
            subscriber_id: 1,
            sendlast_should: 0,
            sendlast_did: 0,
            result_code: 1,
            result_message: "Contact added",
            result_output: "json"
          })
        )
    end
  end
end
