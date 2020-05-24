class PasswordsController < ApplicationController
    skip_before_action :authorized
    skip_before_action :verify_authenticity_token

    def forgot
        @user = User.find_by(email: forgot_password_params[:email])

        if @user
            @user.generate_password_token! # generate pass token
            UserMailer.password_reset_email(@user).deliver_now
            render json: {status: 'ok'}, status: :ok
        else
            render json: {error: ['Email address not found. Please check and try again.']}, status: :not_found
        end
    end

    def reset
        token = params[:token].to_s

        if params[:email].blank?
            return render json: {error: 'Token not present'}
        end

        user = User.find_by(reset_password_token: token)

        if user.present? && user.password_token_valid?
            if user.reset_password!(params[:password])
                render json: {status: 'ok'}, status: :ok
            else
                render json: {error: users.errors.full_messages}, status: :unprocessable_entity
            end
        else
            render json: {error: ['Link not valid or expired. Try generating a new link.']}, status: :not_found
        end
    end

    private
 
    def forgot_password_params
        # TODO: why are params nested
        # eg {"email"=>"example@example.com", "controller"=>"passwords", "action"=>"forgot", "password"=>{"email"=>"example@example.com}}
        params.require(:password).permit(:email)
    end
  
    def user_serializer
        {:only => [:id, :username, :email]} 
    end
end
