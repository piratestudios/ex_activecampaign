defmodule ExActivecampaign.ApiV3 do
  @moduledoc """
    A wrapper for ActiveCampaign API V3 operations.
  """

  alias ExActivecampaign

  @doc """
  Send a GET request to the ActiveCampaign API
  """
  def get(url, query_params \\ %{}, headers \\ []) do
    call(url, :get, nil, query_params, headers)
  end

  @doc """
  Send a POST request to the ActiveCampaign API
  """
  def post(url, body \\ nil, query_params \\ %{}, headers \\ []) do
    call(url, :post, body, query_params, headers)
  end

  defp call(url, method, body, query_params, headers) do
    HTTPoison.request(
      method,
      url |> clean_url,
      body |> encode(content_type(headers)),
      headers |> clean_headers,
      query_params |> clean_params
    )
    |> case do
      {:ok, %{body: raw_body, status_code: code, headers: headers}} ->
        {code, raw_body, headers}

      {:error, %{reason: reason}} ->
        {:error, reason, []}
    end
    |> content_type
    |> decode
  end

  defp auth_header() do
    %{"Api-Token" => ExActivecampaign.api_token()}
  end

  @doc """
  Extract the content type of the headers

  ## Examples

      iex> ExActivecampaign.ApiV3.content_type({:ok, "<xml />", [{"Server", "GitHub.com"}, {"Content-Type", "application/xml; charset=utf-8"}]})
      {:ok, "<xml />", "application/xml"}

      iex> ExActivecampaign.ApiV3.content_type([])
      "application/json"

      iex> ExActivecampaign.ApiV3.content_type([{"Content-Type", "plain/text"}])
      "plain/text"

      iex> ExActivecampaign.ApiV3.content_type([{"Content-Type", "application/xml; charset=utf-8"}])
      "application/xml"

      iex> ExActivecampaign.ApiV3.content_type([{"Server", "GitHub.com"}, {"Content-Type", "application/xml; charset=utf-8"}])
      "application/xml"
  """
  def content_type({ok, body, headers}), do: {ok, body, content_type(headers)}
  def content_type([]), do: "application/json"
  def content_type([{"Content-Type", val} | _]), do: val |> String.split(";") |> List.first()
  def content_type([_ | t]), do: t |> content_type

  @doc """
  Encode the body to pass along to the server

  ## Examples

      iex> ExActivecampaign.ApiV3.encode(%{a: 1}, "application/json")
      "{\\"a\\":1}"

      iex> ExActivecampaign.ApiV3.encode(nil, "application/json")
      ""

      iex> ExActivecampaign.ApiV3.encode("<xml/>", "application/xml")
      "<xml/>"

      iex> ExActivecampaign.ApiV3.encode(%{a: "o ne"}, "application/x-www-form-urlencoded")
      "a=o+ne"

      iex> ExActivecampaign.ApiV3.encode("goop", "application/stuff")
      "goop"
  """
  def encode(nil, "application/json"), do: ""
  def encode(data, "application/json"), do: Poison.encode!(data)
  def encode(data, "application/xml"), do: data
  def encode(data, "application/x-www-form-urlencoded"), do: URI.encode_query(data)
  def encode(data, _), do: data

  @doc """
  Decode the response body

  ## Examples

      iex> ExActivecampaign.ApiV3.decode({:ok, "{\\"a\\": 1}", "application/json"})
      {:ok, %{a: 1}}

      iex> ExActivecampaign.ApiV3.decode({500, "", "application/json"})
      {500, ""}

      iex> ExActivecampaign.ApiV3.decode({:error, "{\\"a\\": 1}", "application/json"})
      {:error, %{a: 1}}

      iex> ExActivecampaign.ApiV3.decode({:ok, "{goop}", "application/json"})
      {:error, "{goop}"}

      iex> ExActivecampaign.ApiV3.decode({:error, "{goop}", "application/json"})
      {:error, "{goop}"}

      iex> ExActivecampaign.ApiV3.decode({:error, :nxdomain, "application/dontcare"})
      {:error, :nxdomain}
  """
  def decode({status, body, _}) when is_atom(body), do: {status, body}
  def decode({status, "", _}), do: {status, ""}

  def decode({status, body, "application/json"}) when is_binary(body) do
    body
    |> Poison.decode(keys: :atoms)
    |> case do
      {:ok, parsed} -> {status, parsed}
      _ -> {:error, body}
    end
  end

  def decode({_status, body, "application/xml"}) do
    decoded_body = body |> :binary.bin_to_list() |> :xmerl_scan.string()

    case decoded_body do
      {:exit, _e} -> {:error, body}
      _ -> {:ok, decoded_body}
    end
  end

  def decode({status, body, _}), do: {status, body}

  @doc """
  Clean the URL, if there is a port, but nothing after, then ensure there's a ending '/' otherwise you will encounter
  something like hackney_url.erl:204: :hackney_url.parse_netloc/2

  ## Examples

      iex> ExActivecampaign.ApiV3.clean_url()
      "http://localhost:8081/v3"

      iex> ExActivecampaign.ApiV3.clean_url(nil)
      "http://localhost:8081/v3"

      iex> ExActivecampaign.ApiV3.clean_url("")
      "http://localhost:8081/v3"

      iex> ExActivecampaign.ApiV3.clean_url("/profile")
      "http://localhost:8081/v3/profile"

      iex> ExActivecampaign.ApiV3.clean_url("http://localhost")
      "http://localhost"

      iex> ExActivecampaign.ApiV3.clean_url("http://localhost:8081/b")
      "http://localhost:8081/b"

      iex> ExActivecampaign.ApiV3.clean_url("http://localhost:8081/v3")
      "http://localhost:8081/v3"
  """
  def clean_url(url \\ nil) do
    url
    |> endpoint_url
    |> slash_cleanup
  end

  defp endpoint_url(endpoint) do
    case endpoint do
      nil -> ExActivecampaign.base_url_v3()
      "" -> ExActivecampaign.base_url_v3()
      "/" <> _ -> ExActivecampaign.base_url_v3() <> endpoint
      _ -> endpoint
    end
  end

  defp slash_cleanup(url) do
    url
    |> String.split(":")
    |> List.last()
    |> Integer.parse()
    |> case do
      {_, ""} -> url <> "/"
      _ -> url
    end
  end

  @doc """
  Allows headers to be provided as a list or map, which makes it easier to ensure defaults are set

  ## Examples

      iex> ExActivecampaign.ApiV3.clean_headers(%{})
      [{"Api-Token", "DEFAULT-ACTIVECAMPAIGN-TOKEN"}, {"Content-Type", "application/json; charset=utf-8"}]

      iex> ExActivecampaign.ApiV3.clean_headers(%{"Content-Type" => "application/xml"})
      [{"Api-Token", "DEFAULT-ACTIVECAMPAIGN-TOKEN"}, {"Content-Type", "application/xml"}]

      iex> ExActivecampaign.ApiV3.clean_headers(%{"Authorization" => "Bearer abc123"})
      [{"Api-Token", "DEFAULT-ACTIVECAMPAIGN-TOKEN"}, {"Authorization","Bearer abc123"}, {"Content-Type", "application/json; charset=utf-8"}]

      iex> ExActivecampaign.ApiV3.clean_headers(%{"Authorization" => "Bearer abc123", "Content-Type" => "application/xml"})
      [{"Api-Token", "DEFAULT-ACTIVECAMPAIGN-TOKEN"}, {"Authorization","Bearer abc123"}, {"Content-Type", "application/xml"}]

      iex> ExActivecampaign.ApiV3.clean_headers([])
      [{"Api-Token", "DEFAULT-ACTIVECAMPAIGN-TOKEN"}, {"Content-Type", "application/json; charset=utf-8"}]

      iex> ExActivecampaign.ApiV3.clean_headers([{"apples", "delicious"}])
      [{"Api-Token", "DEFAULT-ACTIVECAMPAIGN-TOKEN"}, {"Content-Type", "application/json; charset=utf-8"}, {"apples", "delicious"}]

      iex> ExActivecampaign.ApiV3.clean_headers([{"apples", "delicious"}, {"Content-Type", "application/xml"}])
      [{"Api-Token", "DEFAULT-ACTIVECAMPAIGN-TOKEN"}, {"apples", "delicious"}, {"Content-Type", "application/xml"}]
  """
  def clean_headers(h) when is_map(h) do
    Map.merge(auth_header(), %{"Content-Type" => "application/json; charset=utf-8"})
    |> Map.merge(h)
    |> Enum.map(& &1)
  end

  def clean_headers(h) when is_list(h) do
    h
    |> Enum.filter(fn {k, _v} -> k == "Content-Type" end)
    |> case do
      [] ->
        Map.to_list(auth_header()) ++ [{"Content-Type", "application/json; charset=utf-8"} | h]

      _ ->
        Map.to_list(auth_header()) ++ h
    end
  end

  def clean_params(query_params) when query_params == %{}, do: []
  def clean_params(query_params), do: [{:params, query_params}]

  def handle_response({status, body} = _resp) do
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
end
