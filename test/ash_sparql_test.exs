defmodule AshSparqlTest do
  use ExUnit.Case
  doctest AshSparql

  import Mox
  
  # Make sure mocks are verified when the test is run
  setup :verify_on_exit!
  
  test "AshSparql module has expected extensions" do
    assert AshSparql.extensions() == [AshSparql.Dsl, AshSparql.DataLayer.Sparql]
  end
end
