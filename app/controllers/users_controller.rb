class UsersController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authorized, only: [:create]
  wrap_parameters :user, include: [:username, :email, :password, :newPassword]

  def create
    @user = User.create(user_params)
    if @user.valid?
      @token = encode_token(user_id: @user.id)
      render json: { user: @user.to_json(user_serializer), jwt: @token }, status: :created     
    else
      render json: { error: 'failed to create user' }, status: :not_acceptable
    end
  end

  def show
    @user = User.find(decoded_token["user_id"])
    if @user.valid?
      render json: @user.to_json(user_serializer), status: :accepted     
    else
      render json: { message: 'please log in' }, status: :unauthorized
    end
  end

  def update
    if logged_in? && current_user.authenticate(user_params[:password]) && 
        current_user.update(username: user_params[:username], email: user_params[:email], password: user_params[:newPassword])
      render json: current_user.to_json(user_serializer), status: :accepted
    else
      render json: { message: "server error. please try again." }
    end
  end

  def destroy
    if logged_in? 
      current_user.destroy
      render json: { message: "profile deleted. bye!" }
    else
      render json: { message: "server error. please try again." }
    end 
  end

  private

  def user_params
      params.require(:user).permit(:username, :email, :password, :newPassword) 
  end

  def user_serializer
    {:only => [:id, :username, :email]} 
  end
end
