class MockEndpointsController < ApplicationController
  skip_before_action :authenticate

  def handle
    endpoint = Endpoint.find_by(path: request.path, verb: request.method)
    return render_not_found unless endpoint

    response.headers.merge!(endpoint.response_headers)
    render json: endpoint.response_body, status: endpoint.response_code
  end

  private

  def render_not_found
    render json: {
      errors: [ { code: "not_found", detail: "Requested page #{request.path} does not exist" } ]
    }, status: :not_found
  end
end
