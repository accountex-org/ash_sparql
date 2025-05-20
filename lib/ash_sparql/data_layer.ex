defmodule AshSparql.DataLayer do
  @moduledoc """
  An Ash data layer for interacting with SPARQL endpoints.

  This data layer allows Ash resources to query and manipulate data in RDF stores
  using the SPARQL protocol.
  """

  use Ash.DataLayer

  import Ash.Expr

  alias Ash.Actions.{Read, Update, Destroy, Create}
  alias Ash.Error.Framework.{AssumptionFailed, Invalid}
  alias Ash.Resource.Info
  alias Ash.Query

  @doc false
  def can?(_, :async_read), do: true
  def can?(_, :async_update), do: false
  def can?(_, :async_destroy), do: false
  def can?(_, :async_create), do: false
  def can?(_, :composite_primary_key), do: true
  def can?(_, :upsert), do: false
  def can?(_, :filter), do: true
  def can?(_, :boolean_filter), do: true
  def can?(_, :sort), do: true
  def can?(_, :limit), do: true
  def can?(_, :offset), do: true
  def can?(_, :aggregations), do: true

  @doc false
  def resource_to_query(resource) do
    %Ash.Query{resource: resource}
  end

  @doc false
  def run_query(%{query: query}, _state) do
    raise "Not implemented yet"
  end

  @doc false
  def run_query!(_, _state) do
    raise "Not implemented yet"
  end

  @impl true
  def create(_resource, _records, _opts) do
    {:error, "Not implemented yet"}
  end

  @impl true
  def update(_resource, _records, _opts) do
    {:error, "Not implemented yet"}
  end

  @impl true
  def destroy(_resource, _records, _opts) do
    {:error, "Not implemented yet"}
  end

  @impl true
  def transaction(func, _opts) do
    func.()
  end

  @impl true
  def storage_type, do: :sparql

  @doc false
  def default_query(_), do: %{}

  @impl true
  def setup(_), do: :ok
end