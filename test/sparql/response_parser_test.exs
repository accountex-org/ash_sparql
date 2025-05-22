defmodule AshSparql.Sparql.ResponseParserTest do
  use ExUnit.Case, async: true

  alias AshSparql.Sparql.ResponseParser
  alias AshSparql.Test.Person

  describe "parse_json/3" do
    test "parses SELECT results into resource records" do
      # Sample SPARQL SELECT response in JSON format
      response = %{
        "head" => %{"vars" => ["name", "age", "email"]},
        "results" => %{
          "bindings" => [
            %{
              "name" => %{"type" => "literal", "value" => "John Doe"},
              "age" => %{"type" => "typed-literal", "value" => "30", "datatype" => "http://www.w3.org/2001/XMLSchema#integer"},
              "email" => %{"type" => "literal", "value" => "john@example.com"}
            },
            %{
              "name" => %{"type" => "literal", "value" => "Jane Smith"},
              "age" => %{"type" => "typed-literal", "value" => "25", "datatype" => "http://www.w3.org/2001/XMLSchema#integer"},
              "email" => %{"type" => "literal", "value" => "jane@example.com"}
            }
          ]
        }
      }

      {:ok, records} = ResponseParser.parse_json(response, Person)
      
      assert length(records) == 2
      
      [john, jane] = records
      
      assert john.name == "John Doe"
      assert john.age == 30
      assert john.email == "john@example.com"
      
      assert jane.name == "Jane Smith"
      assert jane.age == 25
      assert jane.email == "jane@example.com"
    end

    test "parses ASK query results" do
      response = %{"boolean" => true}
      
      {:ok, [result]} = ResponseParser.parse_json(response, Person)
      assert result.result == true
    end

    test "handles error for invalid response format" do
      response = %{"invalid" => "format"}
      
      assert {:error, {:parse_error, _}} = ResponseParser.parse_json(response, Person)
    end
  end

  describe "parse_json!/3" do
    test "returns records directly for valid response" do
      response = %{
        "head" => %{"vars" => ["name"]},
        "results" => %{
          "bindings" => [
            %{"name" => %{"type" => "literal", "value" => "John Doe"}}
          ]
        }
      }
      
      records = ResponseParser.parse_json!(response, Person)
      assert length(records) == 1
      assert hd(records).name == "John Doe"
    end

    test "raises error for invalid response" do
      response = %{"invalid" => "format"}
      
      assert_raise RuntimeError, fn -> 
        ResponseParser.parse_json!(response, Person)
      end
    end
  end
end