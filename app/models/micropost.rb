class Micropost < ApplicationRecord
  belongs_to :user

  validates :user, presence: true
  validates :content, presence: true,
    length: {maximum: Settings.microposts.content.length.maximum}
  validate :picture_size

  scope :in_desc_time_order, ->{order(created_at: :desc)}
  scope(:feed_of, lambda do |user|
    following_ids = "SELECT followed_id FROM relationships
                     WHERE  follower_id = :user_id"
    where "user_id IN (#{following_ids}) OR user_id = :user_id", user_id: user.id
  end)

  mount_uploader :picture, PictureUploader

  private

  def picture_size
    max_vol = Settings.microposts.picture.size.max_vol

    return unless picture.size > max_vol.megabytes

    errors.add(:picture, t("error_explanation.too_big_file"))
  end
end
