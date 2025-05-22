defmodule AshSparql.Sparql.QueryBuilderTest do
  use ExUnit.Case, async: true

  alias AshSparql.Sparql.QueryBuilder
  alias AshSparql.Test.Person

  describe "build_select/2" do
    test "builds basic SELECT query" do
      query = Ash.Query.new(Person)
      result = QueryBuilder.build_select(query)

      assert String.contains?(result, "PREFIX rdf:")
      assert String.contains?(result, "PREFIX rdfs:")
      assert String.contains?(result, "SELECT ?s ?p ?o")
      assert String.contains?(result, "WHERE { ?s ?p ?o . }")
    end

    test "includes GRAPH when specified" do
      query = Ash.Query.new(Person)
      result = QueryBuilder.build_select(query, graph: "http://example.org/graph")

      assert String.contains?(result, "GRAPH <http://example.org/graph>")
    end

    test "adds LIMIT when specified in query" do
      query = Ash.Query.new(Person) |> Ash.Query.limit(10)
      result = QueryBuilder.build_select(query)

      assert String.contains?(result, "LIMIT 10")
    end

    test "adds OFFSET when specified in query" do
      query = Ash.Query.new(Person) |> Ash.Query.offset(5)
      result = QueryBuilder.build_select(query)

      assert String.contains?(result, "OFFSET 5")
    end
  end
end