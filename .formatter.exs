# Used by "mix format"
[
  import_deps: [:ash, :spark],
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  plugins: [Spark.Formatter],
  export: [
    locals_without_parens: [
      # Ash Resource dsl
      attributes: 1,
      identities: 1,
      actions: 1,
      calculations: 1,
      relationships: 1,
      
      # Ash RDF DSL
      sparql: 1
    ]
  ]
]
