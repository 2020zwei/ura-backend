module Api
    module V1
      class BaseController < ApplicationController
        include DeviseTokenAuth::Concerns::SetUserByToken
        skip_before_action :verify_authenticity_token
        before_action :authenticate_api_v1_user!
        include Rescuable
  
        private
  
        
      end
    end
end