class ApplicationController < ActionController::API
    before_action :snake_case_params

    def test
        if params.has_key?(:login)
            login!(User.first)
        elsif params.has_key?(:logout)
            logout!
        end

        if current_user
            render json: {user: current_user.slice('id', 'username', 'session_token') }
        else
            render json: ['No current user']
        end
    end

    def current_user
        @current_user ||= User.find_by(session_token: session[:session_token])
        @current_user
    end

    def login!(user)
        # debugger
        session[:session_token] = user.reset_session_token!
        @current_user = user
    end

    def logout!  ## might need to be logout!(user)
        current_user.reset_session_token!
        session[:session_token] = nil
        @current_user = nil
    end

    def logged_in?
        !!current_user
    end

    def require_logged_in
        if !logged_in?
            render json: { errors: ['Unauthorized'] }, status: 401
        end
    end

    def require_logged_out
        if logged_in?
            render json: { errors: ['Must be logged out']}, status: 401
        end
    end

    private

    def snake_case_params
        params.deep_transform_keys!(&:underscore)
    end
end
