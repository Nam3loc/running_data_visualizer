ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/mock"
require "webmock/minitest"
require "vcr"
require "omniauth"

# Disable encryption in test environment
ActiveRecord::Encryption.configure(
  primary_key: nil,
  deterministic_key: nil,
  key_derivation_salt: nil
)

# Disable credentials in test environment
Rails.application.credentials = nil

# Set test master key
ENV["RAILS_MASTER_KEY"] = "test_master_key_123456789"

VCR.configure do |config|
  config.cassette_library_dir = "test/vcr_cassettes"
  config.hook_into :webmock
  config.ignore_localhost = true
  config.filter_sensitive_data("<FITBIT_TOKEN>") { ENV["FITBIT_TOKEN"] }
  config.filter_sensitive_data("<FITBIT_REFRESH_TOKEN>") { ENV["FITBIT_REFRESH_TOKEN"] }
  config.allow_http_connections_when_no_cassette = true
  config.default_cassette_options = {
    record: :once,
    match_requests_on: [ :method, :uri, :body ]
  }
end

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
    def sign_in(user)
      # Set up OmniAuth test mode
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:fitbit] = OmniAuth::AuthHash.new(
        provider: "fitbit",
        uid: "12345",
        credentials: {
          token: user.fitbit_token,
          refresh_token: user.fitbit_refresh_token,
          expires_at: user.fitbit_token_expires_at.to_i
        }
      )

      # Set up session
      if @request
        @request.session[:user_id] = user.id
        @request.session[:omniauth] = OmniAuth.config.mock_auth[:fitbit]
        @request.session[:fitbit_token] = user.fitbit_token
        @request.session[:fitbit_refresh_token] = user.fitbit_refresh_token
        @request.session[:fitbit_token_expires_at] = user.fitbit_token_expires_at
      end
      if @controller
        @controller.session[:user_id] = user.id
        @controller.session[:omniauth] = OmniAuth.config.mock_auth[:fitbit]
        @controller.session[:fitbit_token] = user.fitbit_token
        @controller.session[:fitbit_refresh_token] = user.fitbit_refresh_token
        @controller.session[:fitbit_token_expires_at] = user.fitbit_token_expires_at
      end
    end

    def sign_out(user)
      if @request
        @request.session[:user_id] = nil
        @request.session[:omniauth] = nil
        @request.session[:fitbit_token] = nil
        @request.session[:fitbit_refresh_token] = nil
        @request.session[:fitbit_token_expires_at] = nil
      end
      if @controller
        @controller.session[:user_id] = nil
        @controller.session[:omniauth] = nil
        @controller.session[:fitbit_token] = nil
        @controller.session[:fitbit_refresh_token] = nil
        @controller.session[:fitbit_token_expires_at] = nil
      end
    end
  end
end

class ActionDispatch::IntegrationTest
  def sign_in(user)
    # Set up session directly
    post "/auth/fitbit/callback", params: {
      user_id: user.id,
      fitbit_token: user.fitbit_token,
      fitbit_refresh_token: user.fitbit_refresh_token,
      fitbit_token_expires_at: user.fitbit_token_expires_at
    }
    follow_redirect!
  end

  def sign_out(user)
    delete "/signout"
    follow_redirect!
  end

  def setup
    # Ensure we have a session for OmniAuth
    @request.session ||= {}
  end
end
