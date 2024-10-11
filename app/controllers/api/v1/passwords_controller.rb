module Api
    module V1
      class PasswordsController < DeviseTokenAuth::PasswordsController
        include DeviseTokenAuth::Concerns::SetUserByToken
        before_action :set_user_by_token, :only => [:update]
        skip_after_action :update_auth_header, :only => [:create, :edit]
    
        def create
          unless params[:email].present?
            return render json: { success: false, message:  'Attempt to initiate forgot password routine with no email set' },
                          status: :unprocessable_entity
          end
          email = params[:email].downcase
          unless Devise.email_regexp.match?(email)
            return render json: { success: false, message: 'The email must be a valid email address.' },
                          status: :unprocessable_entity
          end
    
          user = User.find_by(email: email)
          if user.present?
    
            ActiveRecord::Base.transaction do
              user.reset_password_token = SecureRandom.hex(10)
              user.reset_password_sent_at = Time.now.utc
              if user.save! && UserMailer.reset_password(user, params[:redirect_url]).deliver_now!
                render json: { success: true, message: 'Reset Password Email Sent' }, status: :ok
              else
                render json: { success: false, message: 'If your email is in our system, a password reset link has been sent.'  },
                       status: :unprocessable_entity
                raise ActiveRecord::Rollback
              end
            end
          else
            render json: { success: false, message:  'Your email is not registered.', error_message: 'If your email is in our system, a password reset link has been sent.'  },
                   status: :unprocessable_entity
          end
        end
    
        # this is where users arrive after visiting the password reset confirmation link
        def edit
          @resource = resource_class.reset_password_by_token({
                                                               reset_password_token: resource_params[:reset_password_token]
                                                             })
    
          if @resource and @resource.id
            client_id  = SecureRandom.urlsafe_base64(nil, false)
            token      = SecureRandom.urlsafe_base64(nil, false)
            token_hash = BCrypt::Password.create(token)
            expiry     = (Time.now + DeviseTokenAuth.token_lifespan).to_i
    
            @resource.tokens[client_id] = {
              token:  token_hash,
              expiry: expiry
            }
    
            # ensure that user is confirmed
            @resource.skip_confirmation! if @resource.devise_modules.include?(:confirmable) && !@resource.confirmed_at
    
            # allow user to change password once without current_password
            @resource.allow_password_change = true;
    
            @resource.save!
            yield if block_given?
    
            redirect_to(@resource.build_auth_url(params[:redirect_url], {
              token:          token,
              client_id:      client_id,
              reset_password: true,
              config:         params[:config]
            }), allow_other_host: true)
          else
            # render_edit_error
            render json: { status: "404", error: "This link has been expired!" }, status: :not_found
          end
        end
    
        def update
          token = request.headers[:token].to_s
          return render json: {success: false, message: 'Token not present' } if request.headers[:token].blank?
          
          user = User.find_by(reset_password_token: token)
          if user.present? && user.password_token_valid?
            if user.reset_password!(params[:password])
              render json: { success: true, message: "Password updated Successfully", status: 'ok' }, status: :ok
            else
              render json: { success: false, message: user.errors.full_messages }, status: :unprocessable_entity
            end
          else
            render json: { success: false, message: 'Link not valid or expired. Try generating a new link.' }, status: :unprocessable_entity
          end
        end
    
        protected
    
        def resource_update_method
          if DeviseTokenAuth.check_current_password_before_update == false or @resource.allow_password_change == true
            "update_attributes"
          else
            "update_with_password"
          end
        end
    
        def render_create_error_missing_email
          render json: {
            success: false,
            errors: [I18n.t("devise_token_auth.passwords.missing_email")]
          }, status: 401
        end
    
        def render_create_error_missing_redirect_url
          render json: {
            success: false,
            errors: [I18n.t("devise_token_auth.passwords.missing_redirect_url")]
          }, status: 401
        end
    
        def render_create_error_not_allowed_redirect_url
          render json: {
            status: 'error',
            data:   resource_data,
            errors: [I18n.t("devise_token_auth.passwords.not_allowed_redirect_url", redirect_url: @redirect_url)]
          }, status: 422
        end
    
        def render_create_success
          render json: {
            success: true,
            data: resource_data,
            message: I18n.t("devise_token_auth.passwords.sended", email: @email)
          }
        end
    
        def render_create_error
          render json: {
            success: false,
            errors: @errors,
          }, status: @error_status
        end
    
        def render_edit_error
          raise ActionController::RoutingError.new('Not Found')
        end
    
        def render_update_error_unauthorized
          render json: {
            success: false,
            errors: ['Unauthorized']
          }, status: 401
        end
    
        def render_update_error_password_not_required
          render json: {
            success: false,
            errors: [I18n.t("devise_token_auth.passwords.password_not_required", provider: @resource.provider.humanize)]
          }, status: 422
        end
    
        def render_update_error_missing_password
          render json: {
            success: false,
            errors: [I18n.t("devise_token_auth.passwords.missing_passwords")]
          }, status: 422
        end
    
        def render_update_success
          render json: {
            success: true,
            data: resource_data,
            message: I18n.t("devise_token_auth.passwords.successfully_updated")
          }
        end
    
        def render_update_error
          return render json: {
            success: false,
            errors: resource_errors
          }, status: 422
        end
    
        private
    
        def resource_params
          params.permit(:email, :password, :password_confirmation, :current_password, :reset_password_token)
        end
    
        def password_resource_params
          params.permit(*params_for_resource(:account_update))
        end
      end
    end
  end