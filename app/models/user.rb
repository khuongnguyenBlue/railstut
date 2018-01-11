class User < ApplicationRecord
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.{1}[a-z]+\z/i
  enum sex: %w(Male Female).freeze

  validates :name, presence: Setting.users.name.presence,
    length: Setting.users.name.length
  validates :email, presence: Setting.users.email.presence,
    length: Setting.users.email.length, format: {with: VALID_EMAIL_REGEX},
    uniqueness: {case_sensitive: false}
  validates :password, presence: Setting.users.password.presence,
    length: Setting.users.password.length
  validates :age, numericality: {only_integer: true, greater_than: Setting.users.age.lwr_bound}
  validates :gender, inclusion: {in: :sex}

  before_save :downcase_email

  has_secure_password

  private

  def downcase_email
    email.downcase!
  end
end
