defmodule AshSparql.Sparql.HttpClient do
  @moduledoc """
  SPARQL client implementation using HTTP protocol with Mint.

  This module implements the `AshSparql.Sparql.Client` behaviour using the HTTP
  protocol, following the SPARQL 1.1 Protocol specification.
  """

  @behaviour AshSparql.Sparql.Client

  alias AshSparql.Sparql.Client

  @typedoc """
  The client state.
  """
  @type t :: %__MODULE__{
          conn: Mint.HTTP.t() | nil,
          endpoint: String.t(),
          headers: [{String.t(), String.t()}],
          request_timeout: pos_integer()
        }

  defstruct conn: nil,
            endpoint: nil,
            headers: [],
            request_timeout: 30_000

  @doc """
  Initialize a new HTTP SPARQL client.

  ## Options

  * `:endpoint` - (Required) The URL of the SPARQL endpoint
  * `:headers` - Additional HTTP headers to include in requests (default: [])
  * `:request_timeout` - The request timeout in milliseconds (default: 30000)
  * `:authentication` - Authentication credentials, can be:
      * `{:basic, username, password}` - HTTP Basic authentication
      * `{:bearer, token}` - Bearer token authentication
      * `{:custom, header_name, value}` - Custom authentication header

  ## Examples

      iex> AshSparql.Sparql.HttpClient.init(endpoint: "http://dbpedia.org/sparql")
      {:ok, %AshSparql.Sparql.HttpClient{endpoint: "http://dbpedia.org/sparql"}}
  """
  @impl Client
  @spec init(Client.options()) :: {:ok, t()} | {:error, term()}
  def init(options) do
    endpoint = Keyword.fetch!(options, :endpoint)

    headers =
      Keyword.get(options, :headers, []) ++
        [
          {"Accept", "application/sparql-results+json"},
          {"Content-Type", "application/x-www-form-urlencoded"}
        ]

    # Add authentication headers if provided
    headers =
      case Keyword.get(options, :authentication) do
        {:basic, username, password} ->
          credentials = Base.encode64("#{username}:#{password}")
          [{"Authorization", "Basic #{credentials}"} | headers]

        {:bearer, token} ->
          [{"Authorization", "Bearer #{token}"} | headers]

        {:custom, header, value} ->
          [{header, value} | headers]

        nil ->
          headers
      end

    client = %__MODULE__{
      endpoint: endpoint,
      headers: headers,
      request_timeout: Keyword.get(options, :request_timeout, 30_000)
    }

    {:ok, client}
  end

  @doc """
  Execute a SPARQL query via HTTP.

  ## Parameters

  * `client` - The client state
  * `query` - The SPARQL query string to execute
  * `options` - Additional options for the query execution

  ## Options

  * `:default_graph` - The default graph URI to query

  ## Examples

      iex> client = %AshSparql.Sparql.HttpClient{endpoint: "http://dbpedia.org/sparql"}
      iex> query = "SELECT * WHERE { ?s ?p ?o } LIMIT 10"
      iex> AshSparql.Sparql.HttpClient.query(client, query, [])
      {:ok, %{...}}
  """
  @impl Client
  @spec query(t(), String.t(), Client.options()) :: Client.query_result()
  def query(client, query, options) do
    uri = URI.parse(client.endpoint)
    
    # Prepare the query parameters
    query_params = [{"query", query}]
    
    # Add default-graph-uri parameter if provided
    query_params =
      case Keyword.get(options, :default_graph) do
        nil -> query_params
        graph -> [{"default-graph-uri", graph} | query_params]
      end
    
    # URL encode the parameters
    body = URI.encode_query(query_params)
    
    # Parse the endpoint URL
    {host, port, scheme} = parse_endpoint(uri)
    
    with {:ok, conn} <- Mint.HTTP.connect(scheme, host, port),
         {:ok, conn, request_ref} <-
           Mint.HTTP.request(conn, "POST", uri.path || "/", client.headers, body),
         {:ok, response} <- receive_response(conn, request_ref, %{status: nil, headers: [], body: ""}),
         :ok <- close_connection(conn) do
      parse_response(response)
    else
      {:error, _conn, error, _responses} -> {:error, error}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Close the HTTP client connection.

  ## Examples

      iex> client = %AshSparql.Sparql.HttpClient{conn: conn}
      iex> AshSparql.Sparql.HttpClient.close(client)
      :ok
  """
  @impl Client
  @spec close(t()) :: :ok | {:error, term()}
  def close(%__MODULE__{conn: nil}), do: :ok

  def close(%__MODULE__{conn: conn}) do
    case Mint.HTTP.close(conn) do
      {:ok, _conn} -> :ok
      {:error, _conn, reason} -> {:error, reason}
    end
  end

  # Private functions

  defp parse_endpoint(uri) do
    scheme = uri.scheme |> String.to_existing_atom()
    port = uri.port || default_port(scheme)
    {uri.host, port, scheme}
  end

  defp default_port(:http), do: 80
  defp default_port(:https), do: 443

  defp receive_response(conn, request_ref, response, timeout \\ 30_000) do
    start_time = System.monotonic_time(:millisecond)
    
    receive do
      message ->
        now = System.monotonic_time(:millisecond)
        time_elapsed = now - start_time
        time_left = max(timeout - time_elapsed, 0)
        
        case Mint.HTTP.stream(conn, message) do
          {:ok, conn, responses} ->
            new_response = process_responses(responses, request_ref, response)
            
            if complete_response?(responses, request_ref) do
              {:ok, new_response}
            else
              receive_response(conn, request_ref, new_response, time_left)
            end
            
          {:error, conn, error, _responses} ->
            {:error, conn, error, response}
        end
    after
      timeout -> {:error, :timeout}
    end
  end

  defp process_responses(responses, request_ref, acc) do
    Enum.reduce(responses, acc, fn
      {:status, ^request_ref, status}, acc -> %{acc | status: status}
      {:headers, ^request_ref, headers}, acc -> %{acc | headers: headers}
      {:data, ^request_ref, data}, acc -> %{acc | body: acc.body <> data}
      _other, acc -> acc
    end)
  end

  defp complete_response?(responses, request_ref) do
    Enum.any?(responses, &match?({:done, ^request_ref}, &1))
  end

  defp close_connection(conn) do
    case Mint.HTTP.close(conn) do
      {:ok, _conn} -> :ok
      {:error, _conn, reason} -> {:error, reason}
    end
  end

  defp parse_response(%{status: status, body: body}) when status in 200..299 do
    case Jason.decode(body) do
      {:ok, parsed} -> {:ok, parsed}
      {:error, reason} -> {:error, {:json_parse_error, reason}}
    end
  end

  defp parse_response(%{status: status, body: body}) do
    {:error, {:http_error, status, body}}
  end
end