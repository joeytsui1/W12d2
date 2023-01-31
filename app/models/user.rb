class User < ApplicationRecord
  has_secure_password

  validates :username, :session_token, :email, presence: true, uniqueness: true
  validates :username, length: {in: 3..30}
  validates :email, length: {in: 3..255}
  validates :email, format: {with: URI::MailTo::EMAIL_REGEXP}
  validates :username, format: {without: URI::MailTo::EMAIL_REGEXP, message: "Cant be an email"}
  validates :password, length: {in: 6..255, allow_nil: true}

  before_validation :ensure_session_token

  def reset_session_token!
    self.session_token = generate_unique_session_token
    self.save!
    session_token
  end

  private

  def self.find_by_credentials (credentials, password)
    if credentials =~ URI::MailTo::EMAIL_REGEXP
      user = User.find_by(email: credentials)
    else
      user = User.find_by(username: credentials)
    end

    if user&.authenticate(password)
      user
    else
      nil
    end
  end

  def generate_unique_session_token
    while true
      token = SecureRandom.urlsafe_base64

      return token unless User.exists?(session_token: token)
    end
  end

  def ensure_session_token
    self.session_token ||= generate_unique_session_token
  end

end
