class User < ApplicationRecord
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.{1}[a-z]+\z/i
  enum sex: %w(male female).freeze
  enum status: {activated: "activated", unactive: "unactive"}

  attr_reader :remember_token, :activation_token, :reset_token

  has_many :microposts, dependent: :destroy
  has_many :active_relationships, inverse_of: :follower,
    class_name: Relationship.name, foreign_key: :follower_id,
    dependent: :destroy
  has_many :passive_relationships, inverse_of: :followed,
    class_name: Relationship.name, foreign_key: :followed_id,
    dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships

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
    activated!
    update_attributes activated_at: Time.zone.now
  end

  def current_user? user
    self == user
  end

  def create_reset_digest
    @reset_token = User.new_token
    update_attributes reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now
  end

  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  def feed
    Micropost.feed_of(self).in_desc_time_order
  end

  def follow other_user
    following << other_user
  end

  def unfollow other_user
    following.delete other_user
  end

  def following? other_user
    following.include? other_user
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
