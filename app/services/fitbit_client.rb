require "http"

class FitbitClient
  class Error < StandardError; end

  BASE_URL = "https://api.fitbit.com/1/user/-"

  def initialize(user)
    @user = user
    @client_id = Rails.application.config.fitbit[:client_id]
    @client_secret = Rails.application.config.fitbit[:client_secret]
    @redirect_uri = Rails.application.config.fitbit[:redirect_uri]
  end

  def get_steps(date)
    make_request("activities/steps/date/#{date}/1d")
  end

  def get_heart_rate(date)
    make_request("activities/heart/date/#{date}/1d")
  end

  def get_sleep(date)
    make_request("sleep/date/#{date}")
  end

  private

  def make_request(endpoint)
    response = HTTP.headers(auth_headers)
                  .get("https://api.fitbit.com/1/user/-/#{endpoint}.json")
    
    case response.code
    when 200
      JSON.parse(response.body.to_s)
    when 401
      refresh_token
      retry
    else
      raise "Fitbit API error: #{response.code}"
    end
  end

  def auth_headers
    {
      "Authorization" => "Bearer #{@user.fitbit_token}",
      "Content-Type" => "application/json"
    }
  end

  def refresh_token
    response = HTTP.post("https://api.fitbit.com/oauth2/token",
      form: {
        grant_type: "refresh_token",
        refresh_token: @user.fitbit_refresh_token,
        client_id: @client_id,
        client_secret: @client_secret
      },
      headers: { "Content-Type" => "application/x-www-form-urlencoded" }
    )

    if response.code == 200
      data = JSON.parse(response.body.to_s)
      @user.update(
        fitbit_token: data["access_token"],
        fitbit_refresh_token: data["refresh_token"],
        fitbit_token_expires_at: Time.current + data["expires_in"].seconds
      )
    else
      raise "Failed to refresh token"
    end
  end
end

