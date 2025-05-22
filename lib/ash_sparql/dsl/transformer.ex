defmodule AshSparql.Dsl.Transformer do
  @moduledoc false
  
  # This transformer registers the `sparql` DSL function
  
  @doc false
  def transform(dsl_state) do
    sparql_config = Spark.Dsl.Extension.get_opt(dsl_state, [:sparql], nil, nil)
    if sparql_config do
      resource = Spark.Dsl.Extension.get_persisted(dsl_state, :module)
      
      quote do
        import AshSparql.Dsl.Sparql
        
        defmodule unquote(Module.concat(resource, "Sparql")) do
          @moduledoc false
          
          @sparql_config unquote(Macro.escape(sparql_config))
          
          def config do
            @sparql_config
          end
        end
      end
    else
      []
    end
  end
end