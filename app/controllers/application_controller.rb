require './.Secrets.rb'

class ApplicationController < ActionController::Base
    before_action :authorized

    def get_correct_environments_secret
        if SECRET_KEY
            SECRET_KEY
        else
            ENV['SECRET_KEY_BASE']
        end
    end

    def get_correct_environments_encryption_algo
        if ENCRYPTION_ALGORITHM
            ENCRYPTION_ALGORITHM
        else
            ENV['ENCRYPTION_ALGORITHM']
        end
    end

    def encode_token(payload)
        JWT.encode(payload, get_correct_environments_secret, get_correct_environments_encryption_algo)
    end
 
    def auth_header
        # { Authentication: 'Bearer <token>' }
        request.headers['Authentication']
    end
    
    def decoded_token
        if !!auth_header
            token = auth_header.split(' ')[1]
            # header: { 'Authentication': 'Bearer <token>' }
            JWT.decode(token, get_correct_environments_secret, true, {algorithm: get_correct_environments_encryption_algo})[0]
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