defmodule AshSparql.Dsl.Sections.Sparql do
  @moduledoc """
  The DSL section for configuring SPARQL endpoint settings in Ash resources.

  This module defines the DSL options for connecting an Ash resource to a SPARQL
  endpoint, including endpoint URL, authentication, and query optimization settings.
  """

  @sparql_schema [
    endpoint: [
      type: :string,
      doc: "The URL of the SPARQL endpoint",
      required: true
    ],
    graph: [
      type: :string,
      doc: "The default graph to query within the RDF store"
    ],
    prefix_map: [
      type: :map,
      doc: "A map of namespace prefixes to URIs",
      default: %{}
    ],
    authentication: [
      type: {:custom, __MODULE__, :validate_authentication, []},
      doc: """
      Authentication configuration for the SPARQL endpoint.

      Can be one of:
      - `{:basic, username, password}` - HTTP Basic authentication
      - `{:bearer, token}` - Bearer token authentication
      - `{:custom, header_name, value}` - Custom authentication header
      """
    ],
    request_timeout: [
      type: :non_neg_integer,
      doc: "Timeout in milliseconds for SPARQL requests",
      default: 30_000
    ],
    connection_pool_size: [
      type: :non_neg_integer,
      doc: "Number of connections to maintain in the pool",
      default: 10
    ],
    http_client_options: [
      type: :keyword_list,
      doc: "Additional options to pass to the HTTP client",
      default: []
    ]
  ]

  @doc """
  Validates authentication configuration for SPARQL endpoints.

  Accepts the following authentication forms:
  - `{:basic, username, password}` - HTTP Basic authentication
  - `{:bearer, token}` - Bearer token authentication
  - `{:custom, header_name, value}` - Custom authentication header
  - `nil` - No authentication

  ## Parameters

  * `value` - The authentication configuration to validate

  ## Returns

  * `{:ok, value}` - If the authentication configuration is valid
  * `{:error, reason}` - If the authentication configuration is invalid
  """
  def validate_authentication(value) do
    case value do
      {:basic, username, password} when is_binary(username) and is_binary(password) ->
        {:ok, value}

      {:bearer, token} when is_binary(token) ->
        {:ok, value}

      {:custom, header, value} when is_binary(header) and is_binary(value) ->
        {:ok, value}

      nil ->
        {:ok, nil}

      _ ->
        {:error, "Authentication must be one of: {:basic, username, password}, {:bearer, token}, or {:custom, header, value}"}
    end
  end

  @doc """
  Returns the schema for the SPARQL DSL section.

  This schema defines all available configuration options for connecting an Ash resource
  to a SPARQL endpoint, including required options like the endpoint URL and optional
  settings like authentication, timeout values, and connection pooling parameters.

  ## Returns

  * A keyword list representing the DSL schema configuration
  """
  def schema do
    @sparql_schema
  end
end