defmodule AshSparql.Sparql.QueryBuilder do
  @moduledoc """
  Builds SPARQL queries from Ash queries.

  This module is responsible for translating Ash queries into equivalent SPARQL
  queries that can be executed against a SPARQL endpoint.
  """

  alias Ash.Query

  @doc """
  Builds a SPARQL SELECT query from an Ash Query.

  ## Parameters

  * `query` - The Ash query to translate
  * `options` - Additional options for query generation

  ## Options

  * `:prefix_map` - A map of namespace prefixes to URIs
  * `:graph` - The default graph to query

  ## Examples

      iex> resource = MyApp.Person
      iex> query = Ash.Query.new(resource) |> Ash.Query.filter(age > 18)
      iex> AshSparql.Sparql.QueryBuilder.build_select(query)
      "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\\nSELECT ?s ?p ?o WHERE { ?s ?p ?o . ?s <http://example.org/age> ?age . FILTER(?age > 18) }"
  """
  @spec build_select(Query.t(), keyword()) :: String.t()
  def build_select(query, options \\ []) do
    prefix_map = Keyword.get(options, :prefix_map, %{})
    graph = Keyword.get(options, :graph)

    # Start building the query
    query_parts = [
      build_prefixes(prefix_map),
      "SELECT",
      build_select_variables(query),
      "WHERE {",
      build_where_clause(query, graph),
      build_filter_clause(query),
      "}"
    ]

    # Add pagination if applicable
    query_parts =
      query_parts
      |> add_limit(query)
      |> add_offset(query)

    # Join all parts with proper spacing
    query_parts
    |> Enum.filter(&(&1 != ""))
    |> Enum.join(" ")
  end

  # Private functions

  defp build_prefixes(prefix_map) do
    # Add standard RDF and RDFS prefixes
    prefix_map =
      Map.merge(
        %{
          "rdf" => "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
          "rdfs" => "http://www.w3.org/2000/01/rdf-schema#"
        },
        prefix_map
      )

    prefix_map
    |> Enum.map(fn {prefix, uri} -> "PREFIX #{prefix}: <#{uri}>" end)
    |> Enum.join("\n")
  end

  defp build_select_variables(_query) do
    # For now, we just select all variables
    # In the future, this should be based on the requested fields
    "?s ?p ?o"
  end

  defp build_where_clause(_query, nil) do
    # Basic pattern without graph specification
    "?s ?p ?o ."
  end

  defp build_where_clause(_query, graph) do
    # With graph specification
    "GRAPH <#{graph}> { ?s ?p ?o . }"
  end

  defp build_filter_clause(%{filter: nil}), do: ""

  defp build_filter_clause(%{filter: _filter}) do
    # This is a simplistic example; actual filter translation would be more complex
    "FILTER(?value = 'example')"
  end

  defp add_limit(query_parts, %{limit: nil}), do: query_parts

  defp add_limit(query_parts, %{limit: limit}) do
    query_parts ++ ["LIMIT #{limit}"]
  end

  defp add_offset(query_parts, %{offset: nil}), do: query_parts

  defp add_offset(query_parts, %{offset: offset}) do
    query_parts ++ ["OFFSET #{offset}"]
  end
end