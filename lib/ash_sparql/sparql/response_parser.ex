defmodule AshSparql.Sparql.ResponseParser do
  @moduledoc """
  Parses SPARQL query results into Ash resource instances.

  This module is responsible for converting the results of SPARQL queries
  (in JSON format) into Ash resource records that can be returned to the user.
  """

  alias Ash.Resource.Info

  @doc """
  Parse a SPARQL JSON response into a list of Ash resource records.

  ## Parameters

  * `response` - The SPARQL JSON response
  * `resource` - The Ash resource module
  * `options` - Additional options for parsing

  ## Returns

  * `{:ok, records}` - A list of parsed resource records
  * `{:error, reason}` - An error occurred during parsing

  ## Examples

      iex> response = %{"head" => %{"vars" => ["s", "p", "o"]}, "results" => %{"bindings" => [...]}}
      iex> AshSparql.Sparql.ResponseParser.parse_json(response, MyApp.Person)
      {:ok, [%MyApp.Person{name: "John", age: 30}, ...]}
  """
  @spec parse_json(map(), module(), keyword()) :: {:ok, list(map())} | {:error, term()}
  def parse_json(response, resource, options \\ []) do
    try do
      records = do_parse_json(response, resource, options)
      {:ok, records}
    rescue
      e -> {:error, {:parse_error, e}}
    end
  end

  @doc """
  Parse a SPARQL JSON response and return records directly.

  Same as `parse_json/3` but returns the records directly or raises an error.

  ## Parameters

  * `response` - The SPARQL JSON response
  * `resource` - The Ash resource module
  * `options` - Additional options for parsing

  ## Returns

  * A list of parsed resource records

  ## Raises

  * If an error occurs during parsing
  """
  @spec parse_json!(map(), module(), keyword()) :: list(map())
  def parse_json!(response, resource, options \\ []) do
    case parse_json(response, resource, options) do
      {:ok, records} -> records
      {:error, reason} -> raise "Failed to parse SPARQL response: #{inspect(reason)}"
    end
  end

  # Private functions

  defp do_parse_json(%{"head" => %{"vars" => vars}, "results" => %{"bindings" => bindings}}, resource, _options) do
    attributes = Info.attributes(resource)
    
    # For each binding in the results...
    bindings
    |> Enum.map(fn binding ->
      # Convert the binding to a resource record
      binding_to_record(binding, vars, resource, attributes)
    end)
    |> Enum.reject(&is_nil/1)
  end

  defp do_parse_json(%{"boolean" => boolean}, _resource, _options) do
    # Handle ASK query results
    [%{result: boolean}]
  end

  defp do_parse_json(response, _resource, _options) do
    # Invalid response format
    raise "Invalid SPARQL response format: #{inspect(response)}"
  end

  defp binding_to_record(binding, vars, resource, attributes) do
    # In a simple implementation, we assume a direct mapping from SPARQL variables to resource attributes
    # In reality, this would be more complex and based on configuration
    
    # Build a map of attribute values
    attributes
    |> Enum.reduce(%{}, fn attr, acc ->
      attr_name = attr.name
      
      # Try to find a matching variable in the binding
      value =
        vars
        |> Enum.find(fn var -> Atom.to_string(attr_name) == var end)
        |> case do
          nil -> nil
          var -> extract_value(binding[var])
        end
      
      if value do
        Map.put(acc, attr_name, value)
      else
        acc
      end
    end)
    |> case do
      # If we have any values, create a record
      map when map != %{} -> struct(resource, map)
      _ -> nil
    end
  end

  defp extract_value(nil), do: nil
  
  defp extract_value(%{"type" => "uri", "value" => value}), do: value
  
  defp extract_value(%{"type" => "literal", "value" => value}), do: value
  
  defp extract_value(%{"type" => "typed-literal", "value" => value, "datatype" => datatype}) do
    # Convert the value based on the datatype
    case datatype do
      "http://www.w3.org/2001/XMLSchema#integer" -> String.to_integer(value)
      "http://www.w3.org/2001/XMLSchema#decimal" -> String.to_float(value)
      "http://www.w3.org/2001/XMLSchema#double" -> String.to_float(value)
      "http://www.w3.org/2001/XMLSchema#boolean" -> value == "true"
      "http://www.w3.org/2001/XMLSchema#dateTime" -> parse_datetime(value)
      _ -> value
    end
  end
  
  defp extract_value(%{"type" => "bnode", "value" => value}), do: "_:#{value}"

  defp parse_datetime(value) do
    case DateTime.from_iso8601(value) do
      {:ok, datetime, _offset} -> datetime
      _ -> value
    end
  end
end