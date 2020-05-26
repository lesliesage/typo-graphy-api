class PasswordsController < ApplicationController
    skip_before_action :authorized
    skip_before_action :verify_authenticity_token
    #Parameters: {"email"=>"eg@eg.com", "code"=>"123", "password"=>"[FILTERED]", "reset"=>{"email"=>"eg@eg.com", "code"=>"123", "password"=>"[FILTERED]"}}
    wrap_parameters "reset" # by default, params from form submit would be nested under object name (password). This nests them under "reset" instead

    def forgot
        @user = User.find_by(email: forgot_password_params[:email])

        if @user
            @user.generate_password_code! # generate pass code
            UserMailer.password_reset_email(@user).deliver_now
            render json: {status: 'ok'}, status: :ok
        else
            render json: {error: ['Email address not found. Please check and try again.']}, status: :not_found
        end
    end

    def reset
        code = forgot_password_params[:code].to_s
        @user = User.find_by(reset_password_code: code)

        if forgot_password_params[:email].blank?
            return render json: {error: 'Email not present'}
        end

        if @user.email===forgot_password_params[:email] && @user.password_code_valid?
            if @user.reset_password!(forgot_password_params[:password]) && @user.authenticate(forgot_password_params[:password])
                token = encode_token({ user_id: @user.id })
                render json: { user: @user.to_json(user_serializer), jwt: token }, status: :accepted
            else
                render json: {error: users.errors.full_messages}, status: :unprocessable_entity
            end
        else
            render json: {error: ['Link not valid or expired. Try generating a new link.']}, status: :not_found
        end
    end

    private
 
    def forgot_password_params
        params.require(:reset).permit(:email, :password, :code)
    end
  
    def user_serializer
        {:only => [:id, :username, :email]} 
    end
end
