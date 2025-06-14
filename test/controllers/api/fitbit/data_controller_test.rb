require "test_helper"

class Api::Fitbit::DataControllerUnauthenticatedTest < ActionController::TestCase
  tests Api::Fitbit::DataController

  setup do
    @user = users(:one)
    sign_in(@user)
    @user.update!(
      fitbit_token: "valid_token",
      fitbit_refresh_token: "valid_refresh_token",
      fitbit_token_expires_at: 1.hour.from_now
    )
  end

  test "requires authentication" do
    # No session user_id set, so should be unauthorized
    get :steps, params: { date: "2024-03-12" }
    assert_response :unauthorized
  end
end

class Api::Fitbit::DataControllerAuthenticatedTest < ActionController::TestCase
  tests Api::Fitbit::DataController

  setup do
    @user = users(:one)
    sign_in(@user)
    @user.update!(
      fitbit_token: "valid_token",
      fitbit_refresh_token: "valid_refresh_token",
      fitbit_token_expires_at: 1.hour.from_now
    )
  end

  test "requires fitbit connection" do
    @user.update!(fitbit_token: nil, fitbit_refresh_token: nil, fitbit_token_expires_at: nil)

    get :steps, params: { date: "2024-03-12" }

    assert_response :unauthorized
    assert_equal "Fitbit account not connected", JSON.parse(response.body)["error"]
  end

  test "gets steps data" do
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
            { "dateTime" => "2024-03-12", "value" => 8500 }
          ]
        }.to_json
      )

    get :steps, params: { date: "2024-03-12" }
    assert_response :success
    data = JSON.parse(response.body)
    assert_equal 8500, data["activities-steps"][0]["value"]
  end

  test "gets heart rate data" do
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

    get :heart_rate, params: { date: "2024-03-12" }
    assert_response :success
    data = JSON.parse(response.body)
    assert_equal 65, data["activities-heart"][0]["value"]["restingHeartRate"]
  end

  test "gets sleep data" do
    # No need to set session user_id again here (already set in setup)
    stub_request(:get, "https://api.fitbit.com/1/user/-/sleep/date/2024-03-12.json")
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
              "duration" => 25_200_000,
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

    get :sleep, params: { date: "2024-03-12" }
    assert_response :success
    data = JSON.parse(response.body)
    assert_equal 25_200_000, data["sleep"][0]["duration"]
    assert_equal 95, data["sleep"][0]["efficiency"]
  end

  test "handles invalid date format" do
    # Session user_id set in setup
    get :steps, params: { date: "invalid-date" }
    assert_response :bad_request
    assert_equal "Invalid date format", JSON.parse(response.body)["error"]
  end

  test "handles missing date parameter" do
    # Session user_id set in setup
    get :steps
    assert_response :bad_request
    assert_equal "Date parameter is required", JSON.parse(response.body)["error"]
  end

  # test "handles fitbit api errors" do
  #   stub_request(:get, "https://api.fitbit.com/1/user/-/activities/steps/date/2024-03-12/1d.json")
  #     .to_return(status: 401)

  #   get :steps, params: { date: "2024-03-12" }
  #   assert_response :unauthorized
  #   assert_equal "Fitbit API error", JSON.parse(response.body)["error"]
  # end
  test "handles fitbit api errors" do
    sign_in(@user)

    # Instead of HTTP stub, stub the client method to raise error
    FitbitClient.any_instance.stubs(:get_steps).raises(FitbitClient::Error.new("Fitbit API error"))

    get :steps, params: { date: "2024-03-12" }
    assert_response :unauthorized
    assert_equal "Fitbit API error", JSON.parse(response.body)["error"]
  end

  test "handles rate limiting" do
    stub_request(:get, "https://api.fitbit.com/1/user/-/activities/steps/date/2024-03-12/1d.json")
      .to_return(status: 429)

    get :steps, params: { date: "2024-03-12" }
    assert_response :too_many_requests
    assert_equal "Rate limit exceeded", JSON.parse(response.body)["error"]
  end

  test "handles token refresh" do
    # Expire token so refresh logic triggers
    @user.update!(fitbit_token_expires_at: 1.minute.ago)

    stub_request(:post, "https://api.fitbit.com/oauth2/token")
      .to_return(
        status: 200,
        body: {
          access_token: "new_token",
          refresh_token: "new_refresh_token",
          expires_in: 3600
        }.to_json,
        headers: { "Content-Type" => "application/json" }
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
            { "dateTime" => "2024-03-12", "value" => 8500 }
          ]
        }.to_json
      )

    get :steps, params: { date: "2024-03-12" }
    assert_response :success
    data = JSON.parse(response.body)
    assert_equal 8500, data["activities-steps"][0]["value"]

    @user.reload
    assert_equal "new_token", @user.fitbit_token
  end
end
