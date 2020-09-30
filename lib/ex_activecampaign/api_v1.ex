defmodule ExActivecampaign.ApiV1 do
  @moduledoc """
    A wrapper for ActiveCampaign API V1 operations.
  """

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
    |> decode
  end

  @doc """
  Extract the content type of the headers

  ## Examples

      iex> ExActivecampaign.ApiV1.content_type({:ok, %{"email" => "johndoe@example.com"}, [{"Content-Type", "application/xml; charset=utf-8"}]})
      {:ok, %{"email" => "johndoe@example.com"}, "application/x-www-form-urlencoded"}

      iex> ExActivecampaign.ApiV1.content_type([])
      "application/x-www-form-urlencoded"

      iex> ExActivecampaign.ApiV1.content_type([{"Content-Type", "plain/text"}])
      "application/x-www-form-urlencoded"

      iex> ExActivecampaign.ApiV1.content_type([{"Content-Type", "application/xml; charset=utf-8"}])
      "application/x-www-form-urlencoded"
  """
  def content_type({status, body, headers}), do: {status, body, content_type(headers)}
  def content_type([]), do: "application/x-www-form-urlencoded"
  def content_type([{"Content-Type", _val} | _]), do: "application/x-www-form-urlencoded"

  @doc """
  Encode the body to pass along to the server

  ## Examples

      iex> ExActivecampaign.ApiV1.encode(%{a: 1}, "application/json")
      {:error, "Unsupported Content-Type for API V1 requests"}

      iex> ExActivecampaign.ApiV1.encode(nil, "application/json")
      {:error, "Unsupported Content-Type for API V1 requests"}

      iex> ExActivecampaign.ApiV1.encode("<xml/>", "application/xml")
      {:error, "Unsupported Content-Type for API V1 requests"}

      iex> ExActivecampaign.ApiV1.encode(%{a: "o ne"}, "application/x-www-form-urlencoded")
      "a=o+ne"

      iex> ExActivecampaign.ApiV1.encode("goop", "application/stuff")
      {:error, "Unsupported Content-Type for API V1 requests"}
  """
  def encode(data, "application/x-www-form-urlencoded"), do: URI.encode_query(data)
  def encode(_, _), do: {:error, "Unsupported Content-Type for API V1 requests"}

  @doc """
  Decode the response body

  ## Examples

      iex> ExActivecampaign.ApiV1.decode({:ok, "{\\"a\\": 1}", "application/json"})
      {:ok, %{"a" => 1}}

      iex> ExActivecampaign.ApiV1.decode({500, "", "application/json"})
      {500, ""}

      iex> ExActivecampaign.ApiV1.decode({:error, "{\\"a\\": 1}", "application/json"})
      {:error, %{"a" => 1}}

      iex> ExActivecampaign.ApiV1.decode({:ok, "{goop}", "application/json"})
      {:error, "{goop}"}

      iex> ExActivecampaign.ApiV1.decode({:error, "{goop}", "application/json"})
      {:error, "{goop}"}

      iex> ExActivecampaign.ApiV1.decode({:error, :nxdomain, "application/dontcare"})
      {:error, :nxdomain}
  """
  def decode({status, "", _}), do: {status, ""}

  def decode({_status, body, "application/xml"}) do
    decoded_body = body |> :binary.bin_to_list() |> :xmerl_scan.string()

    case decoded_body do
      {:exit, _e} -> {:error, body}
      _ -> {:ok, decoded_body}
    end
  end

  def decode({status, body, _}) when is_binary(body) do
    body
    |> Poison.decode()
    |> case do
      {:ok, parsed} -> {status, parsed}
      _ -> {:error, body}
    end
  end

  def decode({status, body, _}), do: {status, body}

  @doc """
  Clean the URL, if there is a port, but nothing after, then ensure there's a ending '/' otherwise you will encounter
  something like hackney_url.erl:204: :hackney_url.parse_netloc/2

  ## Examples

      iex> ExActivecampaign.ApiV1.clean_url()
      "http://localhost:8081/v1"

      iex> ExActivecampaign.ApiV1.clean_url(nil)
      "http://localhost:8081/v1"

      iex> ExActivecampaign.ApiV1.clean_url("")
      "http://localhost:8081/v1"

      iex> ExActivecampaign.ApiV1.clean_url("/profile")
      "http://localhost:8081/v1/profile"

      iex> ExActivecampaign.ApiV1.clean_url("http://localhost")
      "http://localhost"

      iex> ExActivecampaign.ApiV1.clean_url("http://localhost:8081/b")
      "http://localhost:8081/b"

      iex> ExActivecampaign.ApiV1.clean_url("http://localhost:8081")
      "http://localhost:8081/"
  """
  def clean_url(url \\ nil) do
    url
    |> endpoint_url
    |> slash_cleanup
  end

  defp endpoint_url(endpoint) do
    case endpoint do
      nil -> ExActivecampaign.base_url_v1()
      "" -> ExActivecampaign.base_url_v1()
      "/" <> _ -> ExActivecampaign.base_url_v1() <> endpoint
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

      iex> ExActivecampaign.ApiV1.clean_headers(%{})
      [{"Content-Type", "application/x-www-form-urlencoded"}]

      iex> ExActivecampaign.ApiV1.clean_headers(%{"Content-Type" => "application/xml"})
      [{"Content-Type", "application/x-www-form-urlencoded"}]

      iex> ExActivecampaign.ApiV1.clean_headers(%{"Authorization" => "Bearer abc123"})
      [{"Authorization","Bearer abc123"}, {"Content-Type", "application/x-www-form-urlencoded"}]

      iex> ExActivecampaign.ApiV1.clean_headers(%{"Authorization" => "Bearer abc123", "Content-Type" => "application/xml"})
      [{"Authorization","Bearer abc123"}, {"Content-Type", "application/x-www-form-urlencoded"}]

      iex> ExActivecampaign.ApiV1.clean_headers([])
      [{"Content-Type", "application/x-www-form-urlencoded"}]

      iex> ExActivecampaign.ApiV1.clean_headers([{"apples", "delicious"}])
      [{"Content-Type", "application/x-www-form-urlencoded"}, {"apples", "delicious"}]

      iex> ExActivecampaign.ApiV1.clean_headers([{"apples", "delicious"}, {"Content-Type", "application/xml"}])
      [{"Content-Type", "application/x-www-form-urlencoded"}, {"apples", "delicious"}]
  """
  def clean_headers(h) when is_map(h) do
    h
    |> Map.put("Content-Type", "application/x-www-form-urlencoded")
    |> Enum.map(& &1)
  end

  def clean_headers(h) when is_list(h) do
    headers =
      h
      |> Enum.reject(fn {k, _} -> k == "Content-Type" end)

    case headers do
      [] -> [{"Content-Type", "application/x-www-form-urlencoded"}]
      _ -> [{"Content-Type", "application/x-www-form-urlencoded"}] ++ headers
    end
  end

  def clean_params(query_params) when query_params == %{}, do: []
  def clean_params(query_params), do: [{:params, query_params}]

  def handle_response({status, body} = _resp) do
    case status do
      200 -> body
      _ -> %{error_message: "Bad Request"}
    end
  end
end
