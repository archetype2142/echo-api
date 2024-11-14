# frozen_string_literal: true

# Service responsible for serializing and deserializing endpoints following the JSON:API specification.
# See: https://jsonapi.org/format/
#
# Example endpoint JSON structure:
# {
#   "data": {
#     "type": "endpoints",
#     "id": "123",
#     "attributes": {
#       "verb": "GET",
#       "path": "/hello",
#       "response": {
#         "code": 200,
#         "headers": {"Content-Type": "application/json"},
#         "body": {"message": "Hello, World!"}
#       }
#     }
#   }
# }
module EndpointSerializationService
  module_function

  # Converts a single endpoint model into a JSON:API compliant response
  # @param endpoint [Endpoint] The endpoint model to serialize
  # @return [Hash] JSON:API formatted response
  def serialize(endpoint)
    {
      data: {
        type: "endpoints",
        id: endpoint.id,
        attributes: {
          verb: endpoint.verb,
          path: endpoint.path,
          response: endpoint.response
        }
      }
    }
  end

  # Converts a collection of endpoints into a JSON:API compliant response
  # @param endpoints [Array<Endpoint>] Collection of endpoint models
  # @return [Hash] JSON:API formatted response with an array of endpoints
  def serialize_collection(endpoints)
    {
      data: endpoints.map do |endpoint|
        serialize(endpoint)[:data]
      end
    }
  end

  # Converts incoming JSON:API request params into attributes for endpoint creation/update
  # @param params [Hash] The incoming request parameters
  # @return [Hash] Sanitized attributes for endpoint model
  def deserialize(params)
    # Early return if params don't match JSON:API structure
    return {} unless params["data"].is_a?(Hash)

    attributes = params.dig("data", "attributes") || {}
    response = attributes["response"]

    permitted = {}
    permitted[:verb] = attributes["verb"]
    permitted[:path] = attributes["path"]

    if response
      permitted[:response_code] = response["code"]
      permitted[:response_headers] = response["headers"]
      permitted[:response_body] = response["body"].is_a?(String) ? response["body"] : response["body"].to_json
    end

    permitted.compact
  end
end
