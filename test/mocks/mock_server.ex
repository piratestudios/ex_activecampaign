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

  defp post_failure_unprocessable_entity(conn) do
    conn
    |> Plug.Conn.send_resp(422, Poison.encode!(%{message: "Unprocessable Entity"}))
  end

  defp get_failure_not_found(conn) do
    conn
    |> Plug.Conn.send_resp(404, Poison.encode!(%{message: "Not Found"}))
  end

  get "/v3/contacts" do
    case conn.params do
      %{"email" => "johndoe@example.com"} -> contacts_get_success(conn)
      %{"email" => "some-invalid-email"} -> get_failure_not_found(conn)
    end
  end

  get "/v3/contacts/:id" do
    case conn.path_params do
      %{"id" => "1"} -> contacts_get_success(conn)
      %{"id" => "101"} -> get_failure_not_found(conn)
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
        post_failure_unprocessable_entity(conn)
    end
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
        post_failure_unprocessable_entity(conn)
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
        post_failure_unprocessable_entity(conn)
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
        post_failure_bad_request(conn)

      %{"contactList" => %{"list" => 1, "contact" => "invalid-contact", "status" => 1}} ->
        post_failure_bad_request(conn)

      %{"contactList" => %{"list" => 1, "contact" => 1, "status" => "invalid-status"}} ->
        post_failure_bad_request(conn)
    end
  end

  get "/v3/lists/:id" do
    case conn.path_params do
      %{"id" => "1"} -> list_get_success(conn)
      %{"id" => "some-invalid-list-id"} -> get_failure_not_found(conn)
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
