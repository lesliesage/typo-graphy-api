class AuthController < ApplicationController
  skip_before_action :authorized, only: [:create]
  skip_before_action :verify_authenticity_token
 
  def create
    @user = User.find_by(email: user_login_params[:email])
    # User#authenticate comes from BCrypt
    if @user && @user.authenticate(user_login_params[:password])
      # encode token comes from ApplicationController
      token = encode_token({ user_id: @user.id })
      render json: { user: @user.to_json(user_serializer), jwt: token }, status: :accepted
    else
      render json: { message: 'Invalid email or password' }, status: :unauthorized
    end
  end
 
  private
 
  def user_login_params
    # params { auth: {email: 'example@example.com', password: 'pw' } }
    params.require(:auth).permit(:email, :password)
  end

  def user_serializer
    {:only => [:id, :username, :email]} 
  end
end