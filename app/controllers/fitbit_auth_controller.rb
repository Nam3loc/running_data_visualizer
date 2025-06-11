class FitbitAuthController < ApplicationController
  def callback
    auth = request.env["omniauth.auth"]
    user = User.find_or_create_by(fitbit_id: auth.uid)
    user.update(
      fitbit_token: auth.credentials.token,
      fitbit_refresh_token: auth.credentials.refresh_token,
      fitbit_token_expires_at: Time.at(auth.credentials.expires_at)
    )
    session[:user_id] = user.id
    redirect_to dashboard_path, notice: "Successfully connected to Fitbit!"
  end

  def failure
    redirect_to root_path, alert: "Failed to connect to Fitbit. Please try again."
  end
end
