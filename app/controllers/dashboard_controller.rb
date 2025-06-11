class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    if current_user.fitbit_token.present?
      @fitbit_data = {
        steps: fetch_fitbit_data("activities/steps"),
        heart_rate: fetch_fitbit_data("activities/heart"),
        sleep: fetch_fitbit_data("sleep")
      }
    else
      redirect_to "/auth/fitbit", allow_other_host: true
    end
  end

  private

  def authenticate_user!
    unless current_user
      redirect_to "/auth/fitbit", allow_other_host: true
    end
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def fetch_fitbit_data(endpoint)
    response = HTTParty.get(
      "https://api.fitbit.com/1/user/-/#{endpoint}/today.json",
      headers: {
        "Authorization" => "Bearer #{current_user.fitbit_token}",
        "Content-Type" => "application/json"
      }
    )
    JSON.parse(response.body)
  rescue StandardError => e
    Rails.logger.error("Fitbit API Error: #{e.message}")
    nil
  end
end
