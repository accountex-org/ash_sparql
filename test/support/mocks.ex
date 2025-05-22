defmodule AshSparql.Test.Mocks do
  @moduledoc false

  # Define mocks for testing
  Mox.defmock(AshSparql.Test.MockSparqlClient, for: AshSparql.Sparql.Client)
end