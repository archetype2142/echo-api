module ExceptionHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActionController::ParameterMissing do |e|
      render_error("invalid_parameters", "Missing required parameter: #{e.param}", :bad_request)
    end

    rescue_from ActiveRecord::RecordNotFound do |e|
      render_error("not_found", "Requested resource does not exist", :not_found)
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      render_validation_errors(e.record)
    end

    rescue_from JSON::ParserError do |e|
      render_error("invalid_request", "Invalid JSON format", :bad_request)
    end
  end

  private

  def render_error(code, detail, status)
    render json: {
      errors: [
        {
          code: code,
          detail: detail
        }
      ]
    }, status: status
  end

  def render_validation_errors(record)
    errors = record.errors.map do |error|
      {
        code: "validation_error",
        detail: error.full_message
      }
    end
    render json: { errors: errors }, status: :unprocessable_entity
  end
end
