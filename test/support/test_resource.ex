defmodule AshSparql.Test.Person do
  @moduledoc false

  use Ash.Resource,
    data_layer: AshSparql.DataLayer.Sparql,
    extensions: [AshSparql]

  # Define basic attributes for a person
  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
    end

    attribute :age, :integer
    attribute :email, :string
  end

  # SPARQL endpoint configuration
  sparql do
    endpoint "http://example.org/sparql"
    graph "http://example.org/people"
    prefix_map %{
      "ex" => "http://example.org/",
      "foaf" => "http://xmlns.com/foaf/0.1/"
    }
    request_timeout 60_000
    connection_pool_size 5
  end
end

defmodule AshSparql.Test.Registry do
  @moduledoc false
  use Ash.Registry

  entries do
    entry AshSparql.Test.Person
  end
end