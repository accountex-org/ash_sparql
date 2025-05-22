defmodule AshSparql.DataLayer.Sparql do
  @moduledoc """
  An Ash data layer for interacting with SPARQL endpoints.

  This data layer allows Ash resources to query and manipulate data in RDF stores
  using the SPARQL protocol.
  """

  @behaviour Ash.DataLayer

  alias Ash.Query
  alias AshSparql.Sparql.{HttpClient, QueryBuilder, ResponseParser}

  @doc """
  Initializes the SPARQL data layer for an Ash resource.

  This function is called by Ash when a resource using this data layer is
  compiled. It sets up the initial state for the data layer, storing a reference
  to the resource module.

  ## Parameters

  * `resource` - The Ash resource module using this data layer

  ## Returns

  * `{:ok, state}` - The initialized data layer state
  """
  @impl true
  def init(resource) do
    # Initialize the data layer with resource configuration
    {:ok, %{resource: resource}}
  end

  @doc """
  Reports whether the SPARQL data layer supports a specific capability.

  This function is used by Ash to determine which features can be used with
  resources that use this data layer. Each capability represents a specific
  feature or operation that a data layer might support.

  ## Parameters

  * `_resource` - The Ash resource (ignored in this implementation)
  * `capability` - The capability to check for

  ## Returns

  * `true` - If the capability is supported
  * `false` - If the capability is not supported

  ## Supported Capabilities

  * `:async_read` - Supports asynchronous read operations
  * `:filter` - Supports filtering data
  * `:sort` - Supports sorting results
  * `:limit` - Supports limiting the number of results
  * `:offset` - Supports pagination with offsets
  * `:boolean_filter` - Supports boolean operators in filters
  * `:composite_primary_key` - Supports composite primary keys
  """
  @impl true
  def can?(_, :async_read), do: true
  def can?(_, :async_update), do: false
  def can?(_, :async_destroy), do: false
  def can?(_, :async_create), do: false
  def can?(_, :filter), do: true
  def can?(_, :sort), do: true
  def can?(_, :limit), do: true
  def can?(_, :offset), do: true
  def can?(_, :boolean_filter), do: true
  def can?(_, :composite_primary_key), do: true
  def can?(_, :upsert), do: false

  @doc """
  Creates a new Ash query for the specified resource.

  This function initializes a new query object that can be used to build and execute
  SPARQL queries against the resource's configured endpoint.

  ## Parameters

  * `resource` - The Ash resource module to create a query for

  ## Returns

  * A new Ash.Query struct initialized for the specified resource

  ## Examples

      ```elixir
      query = AshSparql.DataLayer.Sparql.resource_to_query(MyApp.Person)
      filtered_query = Ash.Query.filter(query, age > 18)
      ```
  """
  def resource_to_query(resource) do
    # Create a new query for the resource
    Query.new(resource)
  end
  
  @doc """
  Creates a new Ash query for the specified resource within a domain.

  This function initializes a new query object that can be used to build and execute
  SPARQL queries against the resource's configured endpoint, within the context of
  a specific domain.

  ## Parameters

  * `resource` - The Ash resource module to create a query for
  * `domain` - The domain module (ignored in this implementation)

  ## Returns

  * A new Ash.Query struct initialized for the specified resource

  ## Examples

      ```elixir
      query = AshSparql.DataLayer.Sparql.resource_to_query(MyApp.Person, MyApp.Domain)
      filtered_query = Ash.Query.filter(query, age > 18)
      ```
  """
  @impl true
  def resource_to_query(resource, _domain) do
    # Create a new query for the resource, ignoring domain
    Query.new(resource)
  end

  @impl true
  @doc """
  Executes a SPARQL query against the configured endpoint and returns the results.

  This function is the primary entry point for executing queries in the SPARQL data layer. 
  It wraps the `run_query!/2` function in a try/rescue block to ensure that exceptions 
  are caught and returned as error tuples rather than being raised.

  ## Parameters

  * `query_struct` - An Ash query struct containing the query to execute
  * `state` - The data layer state containing the resource configuration

  ## Returns

  * `{:ok, records}` - A list of record maps representing the query results
  * `{:error, exception}` - An error occurred during query execution

  ## Examples

      ```elixir
      # Create a query
      query = AshSparql.DataLayer.Sparql.resource_to_query(MyResource)
      
      # Execute the query
      case AshSparql.DataLayer.Sparql.run_query(query, %{resource: MyResource}) do
        {:ok, results} -> 
          # Process results...
        {:error, error} -> 
          # Handle the error...
      end
      ```
  """
  @impl true
  def run_query(query_struct, state) do
    # Execute the query against the SPARQL endpoint
    try do
      {:ok, run_query!(query_struct, state)}
    rescue
      e ->
        {:error, e}
    end
  end

  @doc """
  Executes a SPARQL query against the configured endpoint and returns the results directly.

  This is a direct query execution function that doesn't catch exceptions. It's used 
  internally by `run_query/2` but can also be used directly when you want to handle 
  exceptions yourself.

  ## Parameters

  * `query_struct` - An Ash query struct containing the query to execute
  * `state` - The data layer state containing the resource configuration

  ## Returns

  * A list of record maps representing the query results

  ## Raises

  * Various exceptions may be raised if the query fails, if the SPARQL endpoint
    is unavailable, or if the response cannot be parsed properly.

  ## Examples

      ```elixir
      # Create a query
      query = AshSparql.DataLayer.Sparql.resource_to_query(MyResource)
      
      # Execute the query directly
      try do
        results = AshSparql.DataLayer.Sparql.run_query!(query, %{resource: MyResource})
        # Process results...
      rescue
        e -> 
          # Handle the exception...
      end
      ```
  """
  def run_query!(query_struct, state) do
    # 1. Extract the resource and query
    %{resource: resource} = state
    %{query: query} = query_struct

    # 2. Get SPARQL configuration from resource
    sparql_config = get_sparql_config(resource)
    
    # 3. Initialize the client
    {:ok, client} = init_client(sparql_config)
    
    # 4. Build the SPARQL query
    sparql_query = QueryBuilder.build_select(query, [
      prefix_map: Map.get(sparql_config, :prefix_map, %{}),
      graph: Map.get(sparql_config, :graph)
    ])
    
    # 5. Execute the query - call the client module directly
    {:ok, response} = HttpClient.query(client, sparql_query, [])
    
    # 6. Parse the response
    {:ok, records} = ResponseParser.parse_json(response, resource)
    
    # 7. Close the client connection - call the client module directly
    :ok = HttpClient.close(client)
    
    # 8. Return the records
    records
  end

  @doc """
  Creates a new resource instance in the data source.

  This function is called by Ash to create a new resource instance. In Phase 1,
  this operation is not yet implemented and returns an error.

  ## Parameters

  * `_resource` - The Ash resource module
  * `_changeset` - The Ash changeset containing the data to create

  ## Returns

  * `{:error, reason}` - The operation is not yet implemented
  """
  @impl true
  def create(_resource, _changeset) do
    # For Phase 1, we only implement read operations
    {:error, "Create operations not yet implemented"}
  end

  @doc """
  Updates an existing resource instance in the data source.

  This function is called by Ash to update an existing resource instance. In Phase 1,
  this operation is not yet implemented and returns an error.

  ## Parameters

  * `_resource` - The Ash resource module
  * `_changeset` - The Ash changeset containing the data to update

  ## Returns

  * `{:error, reason}` - The operation is not yet implemented
  """
  @impl true
  def update(_resource, _changeset) do
    # For Phase 1, we only implement read operations
    {:error, "Update operations not yet implemented"}
  end

  @doc """
  Destroys an existing resource instance in the data source.

  This function is called by Ash to delete an existing resource instance. In Phase 1,
  this operation is not yet implemented and returns an error.

  ## Parameters

  * `_resource` - The Ash resource module
  * `_changeset` - The Ash changeset containing the ID of the record to destroy

  ## Returns

  * `{:error, reason}` - The operation is not yet implemented
  """
  @impl true
  def destroy(_resource, _changeset) do
    # For Phase 1, we only implement read operations
    {:error, "Destroy operations not yet implemented"}
  end

  @doc """
  Executes a function within a transaction context.

  This function is called by Ash to execute operations within a transaction.
  In Phase 1, transactions are not implemented, so the function is executed directly.

  ## Parameters

  * `func` - The function to execute in the transaction
  * `_reason` - The reason for the transaction (unused in Phase 1)
  * `_resource` - The Ash resource module (unused in Phase 1)
  * `_opts` - Additional options for the transaction (unused in Phase 1)

  ## Returns

  * The return value of the executed function
  """
  @impl true
  def transaction(func, _reason, _resource, _opts) do
    # For Phase 1, we don't implement transactions
    # Just execute the function directly
    func.()
  end

  @doc """
  Rolls back a transaction.

  This function is called by Ash to roll back a transaction. In Phase 1,
  transactions are not implemented, so this is a no-op.

  ## Parameters

  * `_resource` - The Ash resource module (unused in Phase 1)
  * `_value` - The value to roll back to (unused in Phase 1)

  ## Returns

  * `:ok` - Always returns ok since rollback is a no-op in Phase 1
  """
  @impl true
  def rollback(_resource, _value) do
    # Since we don't have transactions in Phase 1, rollback is a no-op
    :ok
  end

  @doc """
  Resolves a calculation for a resource instance.

  This function is called by Ash to compute a calculated field. In Phase 1,
  calculations are not implemented and return an error.

  ## Parameters

  * `_calculation` - The calculation to resolve
  * `_record` - The record to calculate the field for
  * `_resource` - The Ash resource module
  * `_opts` - Additional options for the calculation

  ## Returns

  * `{:error, reason}` - The operation is not yet implemented
  """
  def resolve_calculation(_calculation, _record, _resource, _opts) do
    # Not implemented in Phase 1
    {:error, "Calculations not yet implemented"}
  end

  @doc """
  Sets the tenant for a query.

  This function is called by Ash to apply multi-tenancy to a query. In Phase 1,
  multi-tenancy is not implemented and returns an error.

  ## Parameters

  * `_resource` - The Ash resource module
  * `_query` - The query to apply the tenant to
  * `_tenant` - The tenant to set

  ## Returns

  * `{:error, reason}` - The operation is not yet implemented
  """
  @impl true
  def set_tenant(_resource, _query, _tenant) do
    # Not implemented in Phase 1
    {:error, "Multi-tenancy not yet implemented"}
  end

  @doc """
  Returns the storage type identifier for the SPARQL data layer.

  The storage type is a unique identifier that distinguishes this data layer
  from other Ash data layers. This is used internally by Ash for various
  purposes, including determining which data layer to use for a resource.

  ## Returns

  * `:sparql` - The storage type identifier for the SPARQL data layer
  """
  def storage_type, do: :sparql

  # Helper functions

  @doc """
  Retrieves the SPARQL configuration for a resource.

  This internal function extracts the SPARQL configuration from a resource's DSL
  and raises an error if no configuration is found.

  ## Parameters

  * `resource` - The Ash resource module

  ## Returns

  * A map containing the SPARQL configuration options

  ## Raises

  * If no SPARQL configuration is found for the resource
  """
  defp get_sparql_config(resource) do
    # Extract SPARQL configuration from resource DSL
    case AshSparql.Dsl.sparql_config(resource) do
      nil -> raise "No SPARQL configuration found for resource #{inspect(resource)}"
      config -> config
    end
  end

  @doc """
  Initializes a SPARQL client based on the provided configuration.

  This internal function creates a new SPARQL client using the HttpClient module
  and configures it with the settings from the resource's DSL.

  ## Parameters

  * `config` - A map containing the SPARQL configuration options

  ## Returns

  * `{:ok, client}` - The initialized client
  * `{:error, reason}` - If client initialization fails
  """
  defp init_client(config) do
    # Initialize the appropriate client based on configuration
    client_module = HttpClient

    client_module.init([
      endpoint: config.endpoint,
      authentication: Map.get(config, :authentication),
      request_timeout: Map.get(config, :request_timeout, 30_000),
      headers: Map.get(config, :http_client_options, [])
    ])
  end
end