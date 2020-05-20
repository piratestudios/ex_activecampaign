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

  get "/contacts/:id" do
    case conn.path_params do
      %{"id" => "1"} -> contacts_get_success(conn)
      %{"id" => "some-invalid-id"} -> contacts_get_failure_not_found(conn)
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

  defp contacts_get_failure_not_found(conn) do
    conn
    |> Plug.Conn.send_resp(404, Poison.encode!(%{message: "Not Found"}))
  end

  post "/contacts" do
    case conn.params do
      %{"contact" => %{"email" => "johndoe@example.com"}} ->
        contacts_post_success(conn, %{
          "contact" => %{
            "id" => 1,
            "email" => "johndoe@example.com",
            "firstName" => "John",
            "lastName" => "Doe",
            "phone" => "7223224241"
          }
        })

      %{"contact" => %{"email" => "1234"}} ->
        contacts_post_failure_malformed_email(conn)
    end
  end

  post "/contact/sync" do
    case conn.params do
      %{"contact" => %{"email" => "johndoe@example.com"}} ->
        contacts_post_success(conn, %{
          "contact" => %{
            "id" => 1,
            "email" => "johndoe@example.com",
            "firstName" => "John",
            "lastName" => "Doe",
            "phone" => "7223224241"
          }
        })

      %{"contact" => %{"email" => "1234"}} ->
        contacts_post_failure_malformed_email(conn)
    end
  end

  defp contacts_post_success(conn, body) do
    conn
    |> Plug.Conn.send_resp(201, Poison.encode!(body))
  end

  defp contacts_post_failure_malformed_email(conn) do
    conn
    |> Plug.Conn.send_resp(422, Poison.encode!(%{message: "Unprocessable Entity"}))
  end
end
