class FitbitAuthController < ApplicationController
  def callback
    auth = request.env['omniauth.auth']
    
    user = User.find_or_initialize_by(email: auth.info.email)
    user.update(
      fitbit_token: auth.credentials.token,
      fitbit_refresh_token: auth.credentials.refresh_token,
      fitbit_token_expires_at: Time.current + auth.credentials.expires_in.seconds
    )

    session[:user_id] = user.id
    redirect_to root_path, notice: 'Successfully connected to Fitbit!'
  end

  def failure
    redirect_to root_path, alert: 'Failed to connect to Fitbit. Please try again.'
  end
end 