# frozen_string_literal: true

class Unauthenticated < StandardError; end
class Forbidden < StandardError; end
class NotFound < StandardError; end
class InvalidType < StandardError; end
class PayloadTooLarge < StandardError; end
class RequestTimeout < StandardError; end
class ExpectationFailed < StandardError; end

# To handle all exception from one place for all controllers
class Diagnostics
  ResponseInfo = ::Struct.new(:type, :status_code, :message)

  attr_reader :response_info

  def initialize(app)
    @app = app
  end

  def call(env)
    @app.call(env)
  rescue ActionController::RoutingError => e
    request = Rack::Request.new(env)
    rescue_exception(env, e, I18n.t('general.errors.routing_error'), request)
  rescue AbstractController::ActionNotFound => e
    request = Rack::Request.new(env)
    rescue_exception(env, e, I18n.t('general.errors.action_not_found'), request)
  rescue SyntaxError, StandardError => e
    request = Rack::Request.new(env)
    rescue_exception(env, e, nil, request)
  end# frozen_string_literal: true

  class Unauthorized < StandardError; end
  class Forbidden < StandardError; end
  class InvalidType < StandardError; end
  class ExpectationFailed < StandardError; end
  class Unauthenticated < StandardError; end
  class NotFound < StandardError; end
  class PayloadTooLarge < StandardError; end
  class RequestTimeout < StandardError; end
  
  module Rescuable
    extend ActiveSupport::Concern
  
    included do
      rescue_from Exception, with: :rescue_exception
    end
  
    private
  
    # --------------------- EXCEPTION CLASSES ---------------------
    BAD_REQUEST_EXCEPTIONS = ['ActionDispatch::Http::Parameters::ParseError',
                              'ActionController::BadRequest',
                              'ActionController::ParameterMissing',
                              'Rack::QueryParser::ParameterTypeError',
                              'Rack::QueryParser::InvalidParameterError'].freeze
    UNAUTHORIZED_EXCEPTIONS = ['Unauthorized'].freeze
    FORBIDDEN_EXCEPTIONS = ['Forbidden'].freeze
    NOT_FOUND_EXCEPTIONS = ['ActionController::RoutingError',
                            'AbstractController::ActionNotFound',
                            'ActiveRecord::RecordNotFound'].freeze
    METHOD_NOT_ALLOWED_EXCEPTIONS = ['ActionController::MethodNotAllowed',
                                     'ActionController::UnknownHttpMethod'].freeze
    NOT_ACCEPTABLE_EXCEPTIONS = ['InvalidType',
                                 'ActionController::UnknownFormat',
                                 'ActionDispatch::Http::MimeNegotiation::InvalidType'].freeze
    CONFLICT_EXCEPTIONS = ['ActiveRecord::StaleObjectError'].freeze
    EXPECTATION_FAILED_EXCEPTIONS = ['ExpectationFailed'].freeze
    UNPROCESSABLE_ENTITY_EXCEPTIONS = ['ActionController::InvalidAuthenticityToken',
                                       'ActionController::InvalidCrossOriginRequest',
                                       'ActiveRecord::RecordInvalid',
                                       'ActiveRecord::RecordNotSaved'].freeze
    NOT_IMPLEMENTED_EXCEPTIONS = ['ActionController::NotImplemented'].freeze
    UNIQUE_CONSTRAINT_EXCEPTIONS = ['ActiveRecord::RecordNotUnique'].freeze
  
    # --------------------- METHODS ---------------------
    def rescue_exception(exception)
      error_message = exception.message
      status = case exception.class.name
               when *BAD_REQUEST_EXCEPTIONS
                 :bad_request
               when *UNAUTHORIZED_EXCEPTIONS
                 :unauthorized
               when *FORBIDDEN_EXCEPTIONS
                 :forbidden
               when *NOT_FOUND_EXCEPTIONS
                 :not_found
               when *METHOD_NOT_ALLOWED_EXCEPTIONS
                 :method_not_allowed
               when *NOT_ACCEPTABLE_EXCEPTIONS
                 :not_acceptable
               when *CONFLICT_EXCEPTIONS
                 :expectation_failed
               when *EXPECTATION_FAILED_EXCEPTIONS
                 :conflict
               when *UNPROCESSABLE_ENTITY_EXCEPTIONS
                 :unprocessable_entity
               when *NOT_IMPLEMENTED_EXCEPTIONS
                 :not_implemented
               when *UNIQUE_CONSTRAINT_EXCEPTIONS
                 :conflict
               else
                 :internal_server_error
               end
               Rails.logger.error(error_message)
               Rails.logger.info "\n -------------- #{exception.backtrace.first(20).join("\n -------------- ")}"
               body_params = request.body.read
               request_params = request.request_method == "GET" ? request.params : body_params.present? ? body_params : {}
               SlackMessage.message(error_message, exception.backtrace.first(300), request.url, request_params) unless Rails.env == "development"
               code = STATUS_CODES[status]
               if error_message.include?("Validation failed: ")
                  error_message = error_message.gsub(/^Validation failed: /, "")
               end
      render json: { 
          success: false,
          type: "error",
          error_message: "Something went wrong. Please try again!",
          message: error_message }, status: code
    end
  end

  private

  def rescue_exception(env, exception, message = nil, request = nil)
    case env['HTTP_ACCEPT']
    when 'application/json', '*/*'
      rescue_exception_for_json(exception, message, request)
    else
      raise exception
    end
  end

  def rescue_exception_for_json(exception, message = nil, request = nil)
    error_message = message || exception.message
    status_code = ::STATUS_CODES[get_exception_status(exception)]
    backtrace = exception.backtrace.first(15)

    @response_info = ResponseInfo.new('error', status_code, error_message)

    Rails.logger.error(error_message)
    Rails.logger.info "\n -------------- #{backtrace.join("\n -------------- ")}"
    body_params = request.body.read
    params = request.request_method == "GET" ? request.params : body_params.present? ? body_params : {}
    SlackMessage.message(error_message, backtrace.first(300), request.url, params) unless Rails.env == "development"
    [
      status_code, { 'Content-Type' => 'application/json' },
      [(response_info.to_h.compact).to_json]
    ]
  end

  def get_exception_status(exception)
    case exception.class.name
    when *::BAD_REQUEST_EXCEPTIONS then :bad_request
    when *::UNAUTHORIZED_EXCEPTIONS then :unauthorized
    when *::FORBIDDEN_EXCEPTIONS then :forbidden
    when *::NOT_FOUND_EXCEPTIONS then :not_found
    when *::METHOD_NOT_ALLOWED_EXCEPTIONS then :method_not_allowed
    when *::NOT_ACCEPTABLE_EXCEPTIONS then :not_acceptable
    when *::REQUEST_TIMEOUT then :request_timeout
    when *::CONFLICT_EXCEPTIONS then :expectation_failed
    when *::PAYLOAD_TOO_LARGE then :payload_too_large
    when *::EXPECTATION_FAILED_EXCEPTIONS then :conflict
    when *::UNPROCESSABLE_ENTITY_EXCEPTIONS then :unprocessable_entity
    when *::NOT_IMPLEMENTED_EXCEPTIONS then :not_implemented
    else :internal_server_error
    end
  end
end