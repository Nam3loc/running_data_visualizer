class DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :refresh_token_if_needed

  def index
    @steps = fetch_fitbit_data('activities/steps/date/today/1d')
    @heart_rate = fetch_fitbit_data('activities/heart/date/today/1d')
    @sleep = fetch_fitbit_data('sleep/date/today')
  end

  private

  def authenticate_user!
    unless current_user
      redirect_to '/auth/fitbit', allow_other_host: true
    end
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def refresh_token_if_needed
    current_user&.refresh_fitbit_token!
  end

  def fetch_fitbit_data(endpoint)
    return unless current_user

    client = OAuth2::Client.new(
      ENV['FITBIT_CLIENT_ID'],
      ENV['FITBIT_CLIENT_SECRET'],
      site: 'https://api.fitbit.com'
    )

    token = OAuth2::AccessToken.new(client, current_user.fitbit_token)
    response = token.get("/1/user/-/#{endpoint}.json")
    JSON.parse(response.body)
  rescue OAuth2::Error => e
    Rails.logger.error "Fitbit API Error: #{e.message}"
    nil
  end
end 