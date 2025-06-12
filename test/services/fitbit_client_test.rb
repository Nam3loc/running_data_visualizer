require "test_helper"

class FitbitClientTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @user.update(
      fitbit_token: "valid_token",
      fitbit_refresh_token: "valid_refresh_token",
      fitbit_token_expires_at: 1.hour.from_now
    )
    @client = FitbitClient.new(@user)
  end

  test "fetches steps data successfully" do
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

    data = @client.get_steps("2024-03-12")
    assert_equal 8500, data["activities-steps"][0]["value"]
  end

  test "fetches heart rate data successfully" do
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

    data = @client.get_heart_rate("2024-03-12")
    assert_equal 65, data["activities-heart"][0]["value"]["restingHeartRate"]
  end

  test "fetches sleep data successfully" do
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

    data = @client.get_sleep("2024-03-12")
    assert_equal 25200000, data["sleep"][0]["duration"]
    assert_equal 95, data["sleep"][0]["efficiency"]
  end

  test "handles network errors gracefully" do
    stub_request(:get, "https://api.fitbit.com/1/user/-/activities/steps/date/2024-03-12/1d.json")
      .to_timeout

    assert_raises(FitbitClient::Error) do
      @client.get_steps("2024-03-12")
    end
  end

  test "handles empty response data" do
    stub_request(:get, "https://api.fitbit.com/1/user/-/activities/steps/date/2024-03-12/1d.json")
      .to_return(
        status: 200,
        body: { "activities-steps" => [] }.to_json
      )

    data = @client.get_steps("2024-03-12")
    assert_empty data["activities-steps"]
  end

  test "refreshes token when expired" do
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

    data = @client.get_steps("2024-03-12")
    assert_equal 8500, data["activities-steps"][0]["value"]
    @user.reload
    assert_equal "new_token", @user.fitbit_token
  end
end
