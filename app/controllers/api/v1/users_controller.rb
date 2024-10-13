module Api
    module V1
      class UsersController < BaseController
        include DeviseTokenAuth::Concerns::SetUserByToken
        
        def me
          render json: { user: UserSerializer.new(current_api_v1_user) }
        end

        def update
          @user = current_api_v1_user
          current_password = params[:user][:current_password].to_s
          log_out = false
          current_email = @user.email.to_s
          new_email = params[:user][:email].to_s if params[:user][:email].present?
          check_email  = current_email != new_email && !new_email.nil?
          password = params[:user][:password]
          check_password = @user.valid_password?(password)
          if (check_email == true) || (password.present? && check_password == false)
            log_out = true
          end
          if current_password.present? || password.present?
            check_new_pass = current_password.present? && !password.present?
            check_current_pass = !current_password.present? && password.present?
            msg = if check_current_pass
              "current password"
            elsif check_new_pass
              "password"
            end
            return render json: { success: false, message: "Please enter your #{msg}" }, status: :unprocessable_entity if  check_current_pass || check_new_pass
            return render json: { success: false, message: "Password does not match" }, status: :unprocessable_entity unless @user.valid_password?(current_password)
          end
          if @user.update(user_params)
            @user.update(password: password) if password.present? && check_password == false
            render json: { user: @user, log_out: log_out }, status: :ok
          else
            render json: { success: false, message: @user.errors.full_messages.first }, status: :unprocessable_entity
          end

        end

        private
  
        def user_params
          params.require(:user).permit(:email, :password, :password_confirmation, :first_name, :last_name, :username, :profile_image )
        end
      end
    end
end