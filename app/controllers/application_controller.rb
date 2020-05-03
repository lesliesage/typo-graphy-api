class ApplicationController < ActionController::Base
    before_action :authorized

    def secret_key
        Rails.application.credentials.secret_key
      end
    
      def encryption_algorithm
        Rails.application.credentials.encryption_algorithm
      end

    def encode_token(payload)
        JWT.encode(payload, secret_key, encryption_algorithm)
    end
 
    def auth_header
        # { Authentication: 'Bearer <token>' }
        request.headers['Authentication']
    end
    
    def decoded_token
        if !!auth_header
            token = auth_header.split(' ')[1]
            # header: { 'Authentication': 'Bearer <token>' }
            JWT.decode(token, secret_key, true, {algorithm: encryption_algorithm})[0]
        else
            nil
        end
    end
    
    def current_user
        if decoded_token
            user_id = decoded_token['user_id']
            @user = User.find_by(id: user_id)
        end
    end
    
    def logged_in?
        !!current_user
    end
    
    def authorized
        render json: { message: 'No access for you.' }, status: :unauthorized unless logged_in?
    end
end