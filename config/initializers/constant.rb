# --------------------- ERROR STATUS CODES ---------------------
STATUS_CODES = {
  bad_request: 400,
  unauthorized: 401,
  forbidden: 403,
  not_found: 404,
  method_not_allowed: 405,
  not_acceptable: 406,
  request_timeout: 408,
  conflict: 409,
  payload_too_large: 413,
  expectation_failed: 417,
  unprocessable_entity: 422,
  internal_server_error: 500,
  not_implemented: 501
}.freeze

# --------------------- EXCEPTION CLASSES ---------------------
BAD_REQUEST_EXCEPTIONS = ['ActionDispatch::Http::Parameters::ParseError',
                          'ActionController::BadRequest',
                          'ActionController::ParameterMissing',
                          'Rack::QueryParser::ParameterTypeError',
                          'Rack::QueryParser::InvalidParameterError'].freeze
UNAUTHORIZED_EXCEPTIONS = ['Unauthenticated'].freeze
FORBIDDEN_EXCEPTIONS = ['Forbidden', 'Pundit::NotAuthorizedError'].freeze
NOT_FOUND_EXCEPTIONS = ['ActionController::RoutingError',
                        'AbstractController::ActionNotFound',
                        'ActiveRecord::RecordNotFound',
                        'NotFound'].freeze
METHOD_NOT_ALLOWED_EXCEPTIONS = ['ActionController::MethodNotAllowed',
                                 'ActionController::UnknownHttpMethod'].freeze
NOT_ACCEPTABLE_EXCEPTIONS = ['InvalidType',
                             'ActiveRecord::DeleteRestrictionError',
                             'ActionController::UnknownFormat',
                             'ActionDispatch::Http::MimeNegotiation::InvalidType'].freeze
REQUEST_TIMEOUT = ['Net::Timeout', 'RequestTimeout'].freeze
CONFLICT_EXCEPTIONS = ['ActiveRecord::StaleObjectError'].freeze
PAYLOAD_TOO_LARGE = ['PayloadTooLarge'].freeze
EXPECTATION_FAILED_EXCEPTIONS = ['ExpectationFailed'].freeze
UNPROCESSABLE_ENTITY_EXCEPTIONS = ['ActionController::InvalidAuthenticityToken',
                                   'ActionController::InvalidCrossOriginRequest',
                                   'ActiveRecord::RecordInvalid',
                                   'ActiveRecord::RecordNotSaved'].freeze
NOT_IMPLEMENTED_EXCEPTIONS = ['ActionController::NotImplemented'].freeze

IMAGE_URL = "https://picme.s3.amazonaws.com/".freeze