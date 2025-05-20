# AshSparql

An Ash Framework extension that provides a SPARQL data layer for querying RDF data sources.

## Features

- SPARQL query generation from Ash queries
- Integration with RDF data sources via SPARQL endpoints
- Support for common SPARQL 1.1 operations

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ash_sparql` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ash_sparql, "~> 0.1.0"}
  ]
end
```

## Usage

```elixir
defmodule MyApp.Resource do
  use Ash.Resource,
    data_layer: AshSparql.DataLayer

  sparql do
    endpoint "http://dbpedia.org/sparql"
    # Additional configuration options
  end

  # Resource configuration
end
```

## Documentation

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/ash_sparql>.
