class User < ApplicationRecord
  attr_reader :remember_token

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

  def authenticate? remember_token
    return false unless remember_digest
    BCrypt::Password.new(remember_digest).is_password? remember_token
  end

  private

  def downcase_email
    email.downcase!
  end
end
