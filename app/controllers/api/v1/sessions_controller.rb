class Api::V1::SessionsController < DeviseTokenAuth::SessionsController
    include DeviseTokenAuth::Concerns::SetUserByToken
    include Rescuable
    protect_from_forgery unless: -> { request.format.json? }
    respond_to :json
    skip_before_action :verify_authenticity_token
      
      def create
        if params[:email].present? && params[:password].present?
          @resource = User.find_by('LOWER(email) = ?', params[:email].downcase)
          if @resource && valid_params?(:email, :password)
            if @resource.locked_at.present? && ((@resource.locked_at.utc + 20.minutes) < Time.now.utc)
              @resource.update_attribute(:failed_attempts, 0) 
              @resource.update_attribute(:locked_at, nil)
            end
              if @resource.valid_password?(params[:password])
                sign_in(:user, @resource, store: false, bypass: false)
                create_and_assign_token
                auth_header = @resource.create_new_auth_token(@resource.tokens.keys.first)
                token = auth_header["Authorization"].split(" ")[1]
                @resource.update_attribute(:failed_attempts, 0)
                @resource.update_attribute(:locked_at, nil)
                yield if block_given?
                @device_token = params[:device_token]
                DeviceToken.find_or_create_by(user_id: @resource.id, token: @device_token) if @device_token.present?
                render json: { status: "success", data: current_api_v1_user, token: token  }, status: :ok
              else
                @resource.increment!(:failed_attempts)
                @resource.update_attribute(:locked_at, Time.now) if @resource.failed_attempts >= 4
                render_create_error_bad_credentials
              end
          else
            render_create_error_bad_credentials
          end
        else
          render_create_error_bad_credentials
        end
      end
    
      private
      
      def valid_params?(key, value)
        key.present? && value.present?
      end
      
      def get_user_from_database_by_user_id(user_id)
        User.find_by(id: user_id)
      end
  
      def get_user_from_database_by_email(email)
        User.find_by(email: email)
      end
    end