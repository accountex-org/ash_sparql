defmodule AshSparql.Sparql.ClientTest do
  use ExUnit.Case, async: true

  alias AshSparql.Sparql.HttpClient

  describe "init/1" do
    test "initializes client with valid options" do
      options = [endpoint: "http://example.org/sparql"]
      assert {:ok, client} = HttpClient.init(options)
      assert client.endpoint == "http://example.org/sparql"
      assert client.request_timeout == 30_000
    end

    test "initializes client with authentication" do
      options = [
        endpoint: "http://example.org/sparql",
        authentication: {:basic, "username", "password"}
      ]

      assert {:ok, client} = HttpClient.init(options)
      assert client.endpoint == "http://example.org/sparql"
      
      # Check if authorization header is included
      assert Enum.any?(client.headers, fn {key, value} -> 
        key == "Authorization" && String.starts_with?(value, "Basic ")
      end)
    end

    test "raises error when endpoint is missing" do
      assert_raise KeyError, fn -> HttpClient.init([]) end
    end
  end

  # Additional tests would be added here in a real implementation
  # but for now we will just define the structure
end