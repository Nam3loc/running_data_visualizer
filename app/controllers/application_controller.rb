class ApplicationController < ActionController::API
  private

  def authenticate_user!
    unless current_user
      render json: { error: "Not authenticated" }, status: :unauthorized
    end
  end

  def current_user
    token = request.headers["Authorization"]&.split&.last
    return nil unless token

    @current_user ||= User.find_by(api_token: token)
  end
end
class ApplicationController < ActionController::API
  private

  def authenticate_user!
    unless current_user
      render json: { error: "Not authenticated" }, status: :unauthorized
    end
  end

  def current_user
    token = request.headers["Authorization"]&.split&.last
    return nil unless token

    # Find user by token logic here
    @current_user ||= User.find_by(api_token: token)
  end
end
