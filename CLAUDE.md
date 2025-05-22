# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Goal
You are an Elixir software engineer and understand the [Elixir language](https://elixir-lang.org/).
You have read the [Elixir School](https://elixirschool.com/en/) articles in the suggested order.
You are aware of the [Elixir code smells](https://github.com/lucasvegi/Elixir-Code-Smells) and should avoid them when generating code.
When creating Elixir modules make sure to document them (@moduledoc).
When creating Elixir functions make sure to document them (@doc) and provide an example.
When creating Elixir functions make sure to create typespec (@typespec) definitions.
You will be writing code for the [Ash 3.5.9 framework](https://hexdocs.pm/ash/3.5.9/readme.html).
You will be using the [Spark 2.2.54 library](https://hexdocs.pm/spark/2.2.54/get-started-with-spark.html)
You understand how to write well organized DSL with [Spark](https://hexdocs.pm/spark/get-started-with-spark.html).

Your goal is to write an Ash.DataLayer that will be using the [SPARQL 1.1](https://www.w3.org/TR/sparql11-query/) protocol
to create, read, update and destroy resources on a RDF triple store. An internal SPARQL client should be created that will
support both the HTTP and Websocket transport protocol. The preferred HTTP and Websocket library will be Mint.
A design document named 'ash_rdf_sparql_data_layer_design.md' can be found in the docs folder and should be used to 
plan the evolution of the project.

## Current Development Status

### Phase 1: Core SPARQL Client and Basic Queries - NEARLY COMPLETE

#### Completed Items:
- ✅ Project structure setup (mix.exs, dependencies, formatter)
- ✅ Core module implementations:
  - `AshSparql.DataLayer.Sparql` - Main data layer with full Ash.DataLayer behavior
  - `AshSparql.Sparql.Client` - Behavior interface for SPARQL clients
  - `AshSparql.Sparql.HttpClient` - HTTP client implementation using Mint
  - `AshSparql.Sparql.QueryBuilder` - Converts Ash queries to SPARQL
  - `AshSparql.Sparql.ResponseParser` - Parses SPARQL results to Ash records
  - `AshSparql.Dsl.*` - Complete DSL for SPARQL configuration
- ✅ Comprehensive documentation for all public and private functions
- ✅ Read-only operations support with basic filtering

#### Next Steps (remaining Phase 1):
1. **Test basic functionality** - Create a test that queries a public SPARQL endpoint (like DBpedia)
2. **Verify Phase 1 milestone** - Ensure we can successfully query and parse results
3. **Move to Phase 2** - Begin implementing full CRUD operations and connection pooling

#### Phase 1 Implementation Notes:
- Focus is on read-only operations (SELECT queries)
- CRUD operations return "not implemented" errors as planned
- HTTP client uses Mint for low-level control
- DSL supports endpoint configuration, authentication, and basic options
- All Ash.DataLayer callbacks are implemented (some as placeholders)

#### Key Design Decisions Made:
- Using Mint for HTTP client instead of higher-level libraries for better control
- Comprehensive documentation added for all functions including private helpers
- Query builder supports basic patterns, will need expansion in Phase 2
- Response parser handles standard SPARQL JSON format with type conversion

## Commands to run tests/build:
- `mix test` - Run the test suite
- `mix compile` - Compile the project
- `mix docs` - Generate documentation

## Current Architecture:
The implementation follows the design document's Phase 1 specifications with all core components in place and documented.





