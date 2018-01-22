class User < ApplicationRecord
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.{1}[a-z]+\z/i
  enum sex: %w(male female).freeze

  validates :name, presence: true,
    length: {maximum: Settings.users.name.length.maximum}
  validates :email, presence: true,
    length: {maximum: Settings.users.email.length.maximum},
    format: {with: VALID_EMAIL_REGEX}, uniqueness: {case_sensitive: false}
  validates :password, presence: true,
    length: {minimum: Settings.users.password.length.minimum}
  validates :age, presence: true, numericality: {
    only_integer: true, greater_than: Settings.users.age.lwr_bound
  }
  validates :gender, inclusion: {in: sexes.values}

  before_save :downcase_email

  has_secure_password

  private

  def downcase_email
    email.downcase!
  end
end
