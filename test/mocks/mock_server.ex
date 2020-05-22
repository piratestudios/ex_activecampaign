defmodule ExActivecampaign.MockServer do
  @moduledoc """
    A mock ActiveCampaign API server against which to run tests
  """

  use Plug.Router

  plug(Plug.Parsers,
    parsers: [:json],
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

  get "/contacts/:id" do
    case conn.path_params do
      %{"id" => "1"} -> contacts_get_success(conn)
      %{"id" => "some-invalid-id"} -> get_failure_not_found(conn)
    end
  end

  defp contacts_get_success(conn) do
    conn
    |> Plug.Conn.send_resp(
      200,
      Poison.encode!(%{
        contact: %{
          id: conn.params["id"],
          email: "johndoe@example.com",
          firstName: "John",
          lastName: "Doe",
          phone: "7223224241"
        },
        contactLists: []
      })
    )
  end

  post "/contacts" do
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

  post "/contact/sync" do
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

  post "/contactLists" do
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

  get "/lists/:id" do
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
end
