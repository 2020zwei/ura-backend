class Api::V1::RegistrationsController <  DeviseTokenAuth::RegistrationsController
    skip_before_action :verify_authenticity_token
    include DeviseTokenAuth::Concerns::SetUserByToken
    include Rescuable
    before_action :configure_permitted_parameters
    PARAMS = [:email, :password, :password_confirmation, :first_name, :last_name, :profile_image]
    
    def create
      new_user = User.new(permit_params)
      raise ActiveRecord::RecordInvalid,new_user unless new_user.valid?
      if new_user.save!
        auth_header = new_user.create_new_auth_token
        token = auth_header["Authorization"].split(" ")[1]
        sign_in(new_user)
          response.headers.merge!(auth_header)
          render json: {
            status: 'success',
            message: "User created successfully!",
            token: token,
            data: new_user.as_json
          }, status: :ok
        else
          render json: { success: false, message: I18n.t("General.WentWrong") }, status: :unprocessable_entity
        end
    end

    protected
    def permit_params
      params.permit(*PARAMS)
    end
    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: PARAMS)
    end
  end