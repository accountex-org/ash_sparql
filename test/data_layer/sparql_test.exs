defmodule AshSparql.DataLayer.SparqlTest do
  use ExUnit.Case

  import Mox
  alias AshSparql.Test.{Person, Registry}
  alias AshSparql.DataLayer.Sparql

  # Make sure mocks are verified when the test is run
  setup :verify_on_exit!

  describe "data layer capabilities" do
    test "reports correct capabilities" do
      assert Sparql.can?(nil, :async_read) == true
      assert Sparql.can?(nil, :async_update) == false
      assert Sparql.can?(nil, :async_destroy) == false
      assert Sparql.can?(nil, :async_create) == false
      assert Sparql.can?(nil, :filter) == true
      assert Sparql.can?(nil, :sort) == true
      assert Sparql.can?(nil, :limit) == true
      assert Sparql.can?(nil, :offset) == true
      assert Sparql.can?(nil, :boolean_filter) == true
      assert Sparql.can?(nil, :composite_primary_key) == true
      assert Sparql.can?(nil, :upsert) == false
    end

    test "reports correct storage type" do
      assert Sparql.storage_type() == :sparql
    end
  end

  describe "resource_to_query/1" do
    test "creates a query for the resource" do
      query = Sparql.resource_to_query(Person)
      assert query.resource == Person
    end
  end

  test "create/3 returns not implemented error in phase 1" do
    assert {:error, _} = Sparql.create(Person, [], [])
  end

  test "update/3 returns not implemented error in phase 1" do
    assert {:error, _} = Sparql.update(Person, [], [])
  end

  test "destroy/3 returns not implemented error in phase 1" do
    assert {:error, _} = Sparql.destroy(Person, [], [])
  end

  test "transaction/2 just executes the function in phase 1" do
    result = Sparql.transaction(fn -> :transaction_result end, [])
    assert result == :transaction_result
  end

  # More comprehensive tests would be added in a real implementation
  # including mocked client interactions to test query execution
end