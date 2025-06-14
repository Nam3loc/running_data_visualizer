Rails.application.config.fitbit = {
  client_id: ENV["FITBIT_CLIENT_ID"] || "your_client_id_here",
  client_secret: ENV["FITBIT_CLIENT_SECRET"] || "your_client_secret_here",
  redirect_uri: ENV["FITBIT_REDIRECT_URI"] || "http://localhost:3000/auth/fitbit/callback",
  authorize_uri: ENV["FITBIT_AUTHORIZE_URI"] || "https://www.fitbit.com/oauth2/authorize",
  token_uri: ENV["FITBIT_TOKEN_URI"] || "https://api.fitbit.com/oauth2/token"
}
