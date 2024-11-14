# frozen_string_literal: true

# Handles CRUD operations for mock endpoints following the JSON:API specification.
# All actions require token authentication and most require proper content type headers.
#
# @see EndpointSerializationService for request/response format details
class EndpointsController < ApplicationController
  before_action :endpoint, only: [ :show, :update, :destroy ]
  before_action :verify_content_type, only: [ :create, :update ]
  before_action :parse_request_body, only: [ :create, :update ]

  # GET /endpoints
  # Returns a list of all configured mock endpoints
  # @return [JSON] JSON:API formatted list of endpoints
  def index
    endpoints = Endpoint.all
    render json: EndpointSerializationService.serialize_collection(endpoints)
  end

  # GET /endpoints/:id
  # Returns details for a specific endpoint
  # @return [JSON] JSON:API formatted endpoint details
  def show
    render json: EndpointSerializationService.serialize(endpoint)
  end

  # POST /endpoints
  # Creates a new mock endpoint
  # @return [JSON] JSON:API formatted endpoint details on success
  # @return [JSON] Error details on validation failure
  def create
    endpoint = Endpoint.new(endpoint_params)

    if endpoint.save
      # Set Location header as per JSON:API spec for resource creation
      response.headers["Location"] = endpoint_url(endpoint)
      render json: EndpointSerializationService.serialize(endpoint), status: :created
    else
      render_validation_errors(endpoint)
    end
  end

  # PATCH /endpoints/:id
  # Updates an existing mock endpoint
  # @return [JSON] JSON:API formatted endpoint details on success
  # @return [JSON] Error details on validation failure
  def update
    if endpoint.update(endpoint_params)
      render json: EndpointSerializationService.serialize(endpoint)
    else
      render_validation_errors(endpoint)
    end
  end

  # DELETE /endpoints/:id
  # Removes a mock endpoint
  # @return [nil] Returns 204 No Content on success
  def destroy
    endpoint.destroy
    head :no_content
  end

  private

  # Finds the requested endpoint or raises RecordNotFound
  # @return [Endpoint] The requested endpoint
  def endpoint
    @endpoint ||= Endpoint.find(params[:id])
  end

  # Extracts and formats endpoint parameters from the request
  # @return [Hash] Sanitized parameters for endpoint creation/update
  def endpoint_params
    params = EndpointSerializationService.deserialize(@json_params || {})
    return {} if params.empty?
    params
  end

  # Ensures proper content type for POST/PATCH requests
  # @raise [UnsupportedMediaType] If content type is not application/vnd.api+json
  def verify_content_type
    return if request.content_type == "application/vnd.api+json"

    render_error(
      "unsupported_media_type",
      "Content-Type must be application/vnd.api+json",
      :unsupported_media_type
    )
  end

  # Parses JSON request body for POST/PATCH requests
  # @raise [BadRequest] If JSON is malformed
  def parse_request_body
    @json_params = JSON.parse(request.raw_post) if request.raw_post.present?
  rescue JSON::ParserError
    render_error(
      "invalid_request",
      "Invalid JSON format",
      :bad_request
    )
  end
end
