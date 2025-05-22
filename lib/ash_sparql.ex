defmodule AshSparql do
  @moduledoc """
  An Ash Framework extension that provides a SPARQL data layer for querying RDF data sources.

  This module provides the main entry point for the AshSparql extension, allowing Ash
  applications to interact with SPARQL-enabled RDF stores through the Ash resource API.
  """

  @behaviour Ash.Extension

  @doc false
  @spec extensions() :: [module()]
  def extensions do
    [
      AshSparql.Dsl,
      AshSparql.DataLayer.Sparql
    ]
  end
end
