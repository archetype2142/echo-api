# frozen_string_literal: true

# Represents a mock endpoint configuration with its HTTP method, path, and response details.
# Each endpoint must have a unique combination of verb and path.
class Endpoint < ApplicationRecord
  before_create :generate_uuid

  # List of supported HTTP methods
  VALID_HTTP_METHODS = %w[GET POST PUT PATCH DELETE].freeze

  # Reserved paths that cannot be used for mock endpoints
  RESERVED_PATHS = %w[/endpoints].freeze

  validates :verb, presence: true, inclusion: { in: VALID_HTTP_METHODS }
  validates :path, presence: true, format: {
    with: %r{\A/[a-zA-Z0-9_/-]*\z},
    message: "must start with / and can only contain letters, numbers, underscores, and hyphens"
  }
  validates :path, exclusion: {
    in: RESERVED_PATHS,
    message: "cannot use reserved path %{value}"
  }
  validates :response_code, presence: true, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 100,
    less_than: 600
  }
  validates :path, uniqueness: { scope: :verb, message: "and verb combination must be unique" }

  # Returns the complete response configuration
  # @return [Hash] Response with code, headers, and parsed body
  def response
    {
      code: response_code,
      headers: response_headers || {},
      body: parse_response_body
    }
  end

  # Sets the response configuration from a hash
  # @param value [Hash] Response configuration with code, headers, and body
  def response=(value)
    return unless value.is_a?(Hash)

    self.response_code = value[:code] || value["code"]
    self.response_headers = value[:headers] || value["headers"] || {}
    body = value[:body] || value["body"]
    self.response_body = body.is_a?(String) ? body : body.to_json if body.present?
  end

  private

  # Generates a UUID for new records if not already set
  def generate_uuid
    self.id = SecureRandom.uuid if id.blank?
  end

  # Attempts to parse response body as JSON, returns raw body if parsing fails
  # @return [Hash, Array, String] Parsed JSON or raw body string
  def parse_response_body
    return nil if response_body.blank?

    JSON.parse(response_body)
  rescue JSON::ParserError
    response_body
  end
end
