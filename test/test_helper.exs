ExUnit.start()

# Load test support files
Application.ensure_all_started(:mox)

# Set Mox global settings
Mox.defmock(AshSparql.Test.MockClient, for: AshSparql.Sparql.Client)
Mox.set_mox_global()

# Allow async tests with mocks
Application.put_env(:ash_sparql, :client_module, AshSparql.Test.MockClient)
