class User < ApplicationRecord
  has_secure_password

  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }, if: :password_required?

  def fitbit_connected?
    fitbit_token.present?
  end

  def fitbit_token_expired?
    fitbit_token_expires_at < Time.current
  end

  def refresh_fitbit_token!
    return unless fitbit_token_expired?

    client = OAuth2::Client.new(
      ENV["FITBIT_CLIENT_ID"],
      ENV["FITBIT_CLIENT_SECRET"],
      site: "https://api.fitbit.com",
      token_url: "/oauth2/token"
    )

    token = OAuth2::AccessToken.new(client, fitbit_token, refresh_token: fitbit_refresh_token)
    new_token = token.refresh!

    update(
      fitbit_token: new_token.token,
      fitbit_refresh_token: new_token.refresh_token,
      fitbit_token_expires_at: Time.at(new_token.expires_at)
    )
  end

  private

  def password_required?
    new_record? || password.present?
  end
end
