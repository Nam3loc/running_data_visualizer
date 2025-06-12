require "test_helper"

class Api::Fitbit::DataControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @user.update(
      fitbit_token: "valid_token",
      fitbit_refresh_token: "valid_refresh_token",
      fitbit_token_expires_at: 1.hour.from_now
    )
  end

  test "requires authentication" do
    get api_fitbit_steps_path(date: "2024-03-12")
    assert_response :unauthorized
  end

  test "requires fitbit connection" do
    @user.update(fitbit_token: nil)
    post "/auth/fitbit/callback", params: {
      user_id: @user.id,
      fitbit_token: nil,
      fitbit_refresh_token: nil,
      fitbit_token_expires_at: nil
    }

    get api_fitbit_steps_path(date: "2024-03-12")
    assert_response :unauthorized
    assert_equal "Fitbit account not connected", JSON.parse(response.body)["error"]
  end

  test "gets steps data" do
    post "/auth/fitbit/callback", params: {
      user_id: @user.id,
      fitbit_token: @user.fitbit_token,
      fitbit_refresh_token: @user.fitbit_refresh_token,
      fitbit_token_expires_at: @user.fitbit_token_expires_at
    }

    stub_request(:get, "https://api.fitbit.com/1/user/-/activities/steps/date/2024-03-12/1d.json")
      .with(
        headers: {
          "Authorization" => "Bearer valid_token",
          "Content-Type" => "application/json"
        }
      )
      .to_return(
        status: 200,
        body: {
          "activities-steps" => [
            {
              "dateTime" => "2024-03-12",
              "value" => "8500"
            }
          ]
        }.to_json
      )

    get api_fitbit_steps_path(date: "2024-03-12")
    assert_response :success
    data = JSON.parse(response.body)
    assert_equal 8500, data["activities-steps"][0]["value"]
  end

  test "gets heart rate data" do
    post "/auth/fitbit/callback", params: {
      user_id: @user.id,
      fitbit_token: @user.fitbit_token,
      fitbit_refresh_token: @user.fitbit_refresh_token,
      fitbit_token_expires_at: @user.fitbit_token_expires_at
    }

    stub_request(:get, "https://api.fitbit.com/1/user/-/activities/heart/date/2024-03-12/1d.json")
      .with(
        headers: {
          "Authorization" => "Bearer valid_token",
          "Content-Type" => "application/json"
        }
      )
      .to_return(
        status: 200,
        body: {
          "activities-heart" => [
            {
              "dateTime" => "2024-03-12",
              "value" => {
                "restingHeartRate" => 65,
                "heartRateZones" => [
                  {
                    "name" => "Out of Range",
                    "min" => 30,
                    "max" => 90,
                    "minutes" => 120
                  }
                ]
              }
            }
          ]
        }.to_json
      )

    get api_fitbit_heart_rate_path(date: "2024-03-12")
    assert_response :success
    data = JSON.parse(response.body)
    assert_equal 65, data["activities-heart"][0]["value"]["restingHeartRate"]
  end

  test "gets sleep data" do
    post "/auth/fitbit/callback", params: {
      user_id: @user.id,
      fitbit_token: @user.fitbit_token,
      fitbit_refresh_token: @user.fitbit_refresh_token,
      fitbit_token_expires_at: @user.fitbit_token_expires_at
    }

    stub_request(:get, "https://api.fitbit.com/1.2/user/-/sleep/date/2024-03-12.json")
      .with(
        headers: {
          "Authorization" => "Bearer valid_token",
          "Content-Type" => "application/json"
        }
      )
      .to_return(
        status: 200,
        body: {
          "sleep" => [
            {
              "dateOfSleep" => "2024-03-12",
              "duration" => 25200000,
              "efficiency" => 95,
              "startTime" => "2024-03-12T22:00:00.000",
              "endTime" => "2024-03-13T05:00:00.000",
              "levels" => {
                "summary" => {
                  "deep" => { "minutes" => 60 },
                  "light" => { "minutes" => 240 },
                  "rem" => { "minutes" => 90 },
                  "wake" => { "minutes" => 30 }
                }
              }
            }
          ]
        }.to_json
      )

    get api_fitbit_sleep_path(date: "2024-03-12")
    assert_response :success
    data = JSON.parse(response.body)
    assert_equal 25200000, data["sleep"][0]["duration"]
    assert_equal 95, data["sleep"][0]["efficiency"]
  end

  test "handles invalid date format" do
    post "/auth/fitbit/callback", params: {
      user_id: @user.id,
      fitbit_token: @user.fitbit_token,
      fitbit_refresh_token: @user.fitbit_refresh_token,
      fitbit_token_expires_at: @user.fitbit_token_expires_at
    }

    get api_fitbit_steps_path(date: "invalid-date")
    assert_response :bad_request
    assert_equal "Invalid date format", JSON.parse(response.body)["error"]
  end

  test "handles missing date parameter" do
    post "/auth/fitbit/callback", params: {
      user_id: @user.id,
      fitbit_token: @user.fitbit_token,
      fitbit_refresh_token: @user.fitbit_refresh_token,
      fitbit_token_expires_at: @user.fitbit_token_expires_at
    }

    get api_fitbit_steps_path
    assert_response :bad_request
    assert_equal "Date parameter is required", JSON.parse(response.body)["error"]
  end

  test "handles fitbit api errors" do
    post "/auth/fitbit/callback", params: {
      user_id: @user.id,
      fitbit_token: @user.fitbit_token,
      fitbit_refresh_token: @user.fitbit_refresh_token,
      fitbit_token_expires_at: @user.fitbit_token_expires_at
    }

    stub_request(:get, "https://api.fitbit.com/1/user/-/activities/steps/date/2024-03-12/1d.json")
      .to_return(status: 401)

    get api_fitbit_steps_path(date: "2024-03-12")
    assert_response :unauthorized
    assert_equal "Fitbit API error", JSON.parse(response.body)["error"]
  end

  test "handles rate limiting" do
    post "/auth/fitbit/callback", params: {
      user_id: @user.id,
      fitbit_token: @user.fitbit_token,
      fitbit_refresh_token: @user.fitbit_refresh_token,
      fitbit_token_expires_at: @user.fitbit_token_expires_at
    }

    stub_request(:get, "https://api.fitbit.com/1/user/-/activities/steps/date/2024-03-12/1d.json")
      .to_return(status: 429)

    get api_fitbit_steps_path(date: "2024-03-12")
    assert_response :too_many_requests
    assert_equal "Rate limit exceeded", JSON.parse(response.body)["error"]
  end

  test "handles token refresh" do
    post "/auth/fitbit/callback", params: {
      user_id: @user.id,
      fitbit_token: @user.fitbit_token,
      fitbit_refresh_token: @user.fitbit_refresh_token,
      fitbit_token_expires_at: @user.fitbit_token_expires_at
    }
    @user.update(fitbit_token_expires_at: 1.minute.ago)

    stub_request(:post, "https://api.fitbit.com/oauth2/token")
      .with(
        body: {
          grant_type: "refresh_token",
          refresh_token: "valid_refresh_token",
          client_id: "test_client_id",
          client_secret: "test_client_secret"
        },
        headers: {
          "Content-Type" => "application/x-www-form-urlencoded"
        }
      )
      .to_return(
        status: 200,
        body: {
          access_token: "new_token",
          refresh_token: "new_refresh_token",
          expires_in: 3600
        }.to_json
      )

    stub_request(:get, "https://api.fitbit.com/1/user/-/activities/steps/date/2024-03-12/1d.json")
      .with(
        headers: {
          "Authorization" => "Bearer new_token",
          "Content-Type" => "application/json"
        }
      )
      .to_return(
        status: 200,
        body: {
          "activities-steps" => [
            {
              "dateTime" => "2024-03-12",
              "value" => "8500"
            }
          ]
        }.to_json
      )

    get api_fitbit_steps_path(date: "2024-03-12")
    assert_response :success
    data = JSON.parse(response.body)
    assert_equal 8500, data["activities-steps"][0]["value"]
    @user.reload
    assert_equal "new_token", @user.fitbit_token
  end
end
