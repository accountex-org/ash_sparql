defmodule AshSparql.Dsl do
  @moduledoc """
  The DSL extension for using SPARQL with Ash resources.

  This extension provides the ability to configure SPARQL endpoints and options
  for querying RDF data sources through the Ash resource API.

  ## Usage

  ```elixir
  defmodule MyApp.Person do
    use Ash.Resource,
      extensions: [AshSparql]

    attributes do
      uuid_primary_key :id
      attribute :name, :string
      attribute :age, :integer
    end

    # Configure SPARQL endpoint
    sparql do
      endpoint "http://dbpedia.org/sparql"
      graph "http://dbpedia.org/resource/"
      prefix_map %{
        "dbo" => "http://dbpedia.org/ontology/",
        "dbr" => "http://dbpedia.org/resource/"
      }
    end
  end
  ```
  """

  alias AshSparql.Dsl.Sections.Sparql

  @sparql_section %Spark.Dsl.Section{
    name: :sparql,
    describe: "Configure SPARQL endpoint settings",
    schema: Sparql.schema(),
    entities: [],
    imports: []
  }

  use Spark.Dsl.Extension,
    sections: [@sparql_section],
    transformers: [
      # Add transformers here when needed
    ],
    verifiers: [
      # Add verifiers here when needed
    ]

  @doc """
  Determine if a resource uses the `sparql` extension.

  ## Examples

      iex> AshSparql.Dsl.extension?(SomeResource)
      true
      
      iex> AshSparql.Dsl.extension?(OtherResource)
      false
  """
  @spec extension?(Ash.Resource.t()) :: boolean()
  def extension?(resource) do
    extensions = Spark.extensions(resource)
    __MODULE__ in extensions
  end

  @doc """
  Get the SPARQL configuration from the DSL.

  ## Parameters

  * `resource` - The Ash resource.

  ## Returns

  A map containing the SPARQL configuration options.

  ## Examples

      iex> AshSparql.Dsl.sparql_config(MyApp.Person)
      %{
        endpoint: "http://dbpedia.org/sparql",
        graph: "http://dbpedia.org/resource/",
        prefix_map: %{"dbo" => "http://dbpedia.org/ontology/"}
      }
  """
  @spec sparql_config(Ash.Resource.t()) :: map() | nil
  def sparql_config(resource) do
    Spark.Dsl.Extension.get_opt(resource, [:sparql], nil, nil)
  end
end