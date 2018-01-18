class User < ApplicationRecord
  attr_reader :remember_token, :activation_token, :reset_token

  scope :activated, ->{where activated: true}

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.{1}[a-z]+\z/i
  enum sex: %w(male female).freeze

  validates :name, presence: true,
    length: {maximum: Settings.users.name.length.maximum}
  validates :email, presence: true,
    length: {maximum: Settings.users.email.length.maximum},
    format: {with: VALID_EMAIL_REGEX}, uniqueness: {case_sensitive: false}
  validates :password, allow_blank: true,
    length: {minimum: Settings.users.password.length.minimum}
  validates :age, presence: true, numericality: {
    only_integer: true, greater_than: Settings.users.age.lwr_bound
  }
  validates :gender, inclusion: {in: sexes.values}

  before_save :downcase_email
  before_create :create_activation_digest

  has_secure_password

  class << self
    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create string, cost: cost
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def remember
    @remember_token = User.new_token
    update_attributes remember_digest: User.digest(remember_token)
  end

  def forget
    update_attributes remember_digest: nil
  end

  def authenticate? attribute, token
    digest = send "#{attribute}_digest"
    return false unless digest
    BCrypt::Password.new(digest).is_password? token
  end

  def activate
    update_attributes activated: true, activated_at: Time.zone.now
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def current_user? user
    self == user
  end

  def create_reset_digest
    @reset_token = User.new_token
    update_attributes reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  private

  def downcase_email
    email.downcase!
  end

  def create_activation_digest
    @activation_token = User.new_token
    self.activation_digest = User.digest activation_token
  end
end
