defmodule AshSparql.Dsl.Sparql do
  @moduledoc """
  Provides DSL macros for configuring SPARQL endpoints in Ash resources.
  """
  
  @doc """
  Configure SPARQL-specific options for a resource.

  ## Options

  * `:endpoint` - The URL of the SPARQL endpoint.
  * `:graph` - The default graph to query within the RDF store.
  * `:prefix_map` - A map of namespace prefixes to full URIs.
  * `:authentication` - Authentication credentials for the endpoint.
  * `:request_timeout` - Timeout in milliseconds for SPARQL requests.
  * `:connection_pool_size` - Number of connections to maintain in the pool.
  * `:http_client_options` - Additional options to pass to the HTTP client.

  ## Example

      sparql do
        endpoint "http://dbpedia.org/sparql"
        graph "http://dbpedia.org/resource/"
        prefix_map %{
          "dbo" => "http://dbpedia.org/ontology/",
          "dbr" => "http://dbpedia.org/resource/"
        }
      end
  """
  defmacro sparql(do: block) do
    quote do
      require Spark.Dsl.Extension
      Spark.Dsl.Extension.set_option(AshSparql.Dsl, :sparql, [])
      
      import AshSparql.Dsl.Sparql
      unquote(block)
    end
  end
  
  @doc """
  Set the SPARQL endpoint URL for the resource.
  """
  defmacro endpoint(url) do
    quote do
      require Spark.Dsl.Extension
      Spark.Dsl.Extension.set_option(AshSparql.Dsl, [:sparql, :endpoint], unquote(url))
    end
  end
  
  @doc """
  Set the default graph to query.
  """
  defmacro graph(uri) do
    quote do
      require Spark.Dsl.Extension
      Spark.Dsl.Extension.set_option(AshSparql.Dsl, [:sparql, :graph], unquote(uri))
    end
  end
  
  @doc """
  Define namespace prefix mappings for the resource.
  """
  defmacro prefix_map(map) do
    quote do
      require Spark.Dsl.Extension
      Spark.Dsl.Extension.set_option(AshSparql.Dsl, [:sparql, :prefix_map], unquote(map))
    end
  end
  
  @doc """
  Configure authentication for the SPARQL endpoint.
  """
  defmacro authentication(auth) do
    quote do
      require Spark.Dsl.Extension
      Spark.Dsl.Extension.set_option(AshSparql.Dsl, [:sparql, :authentication], unquote(auth))
    end
  end
  
  @doc """
  Set the request timeout in milliseconds.
  """
  defmacro request_timeout(timeout) do
    quote do
      require Spark.Dsl.Extension
      Spark.Dsl.Extension.set_option(AshSparql.Dsl, [:sparql, :request_timeout], unquote(timeout))
    end
  end
  
  @doc """
  Set the connection pool size.
  """
  defmacro connection_pool_size(size) do
    quote do
      require Spark.Dsl.Extension
      Spark.Dsl.Extension.set_option(AshSparql.Dsl, [:sparql, :connection_pool_size], unquote(size))
    end
  end
  
  @doc """
  Set additional HTTP client options.
  """
  defmacro http_client_options(options) do
    quote do
      require Spark.Dsl.Extension
      Spark.Dsl.Extension.set_option(AshSparql.Dsl, [:sparql, :http_client_options], unquote(options))
    end
  end
end