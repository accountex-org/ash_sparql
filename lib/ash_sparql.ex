defmodule AshSparql do
  @moduledoc """
  An Ash Framework extension that provides a SPARQL data layer for querying RDF data sources.

  This module provides the main entry point for the AshSparql extension.
  """

  use Ash.Extension

  @doc false
  def extensions, do: [AshSparql.DataLayer]
end
