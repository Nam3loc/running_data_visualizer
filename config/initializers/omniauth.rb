Rails.application.config.middleware.use OmniAuth::Builder do
  provider :fitbit, ENV["FITBIT_CLIENT_ID"], ENV["FITBIT_CLIENT_SECRET"], scope: "activity heartrate location nutrition profile settings sleep social weight"
end
