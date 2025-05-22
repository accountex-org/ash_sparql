defmodule AshSparql.Sparql.Client do
  @moduledoc """
  Behaviour defining the SPARQL client interface.

  This module standardizes the interface for SPARQL clients, allowing different
  implementations (HTTP, WebSocket) to be used interchangeably.
  """

  @typedoc """
  Options for configuring a SPARQL client.
  """
  @type options :: keyword()

  @typedoc """
  The result of a SPARQL query execution.
  """
  @type query_result :: {:ok, map()} | {:error, term()}

  @doc """
  Initialize a new SPARQL client with the given options.

  ## Options

  The specific options depend on the implementation, but common options include:

  * `:endpoint` - The URL of the SPARQL endpoint
  * `:timeout` - The request timeout in milliseconds
  * `:headers` - Additional HTTP headers to include in requests
  * `:authentication` - Authentication credentials
  """
  @callback init(options()) :: {:ok, term()} | {:error, term()}

  @doc """
  Execute a SPARQL query and return the results.

  This function sends a SPARQL query to the endpoint and parses the response
  into a standardized format.

  ## Parameters

  * `client` - The client state returned by `init/1`
  * `query` - The SPARQL query string to execute
  * `options` - Additional options for the query execution
  """
  @callback query(term(), String.t(), options()) :: query_result()

  @doc """
  Close the SPARQL client connection.

  This function cleans up any resources used by the client.
  """
  @callback close(term()) :: :ok | {:error, term()}
end