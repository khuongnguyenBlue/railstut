class Micropost < ApplicationRecord
  belongs_to :user

  validates :user, presence: true
  validates :content, presence: true,
    length: {maximum: Settings.microposts.content.length.maximum}
  validate :picture_size

  scope :in_desc_time_order, ->{order(created_at: :desc)}

  mount_uploader :picture, PictureUploader

  private

  def picture_size
    max_vol = Settings.microposts.picture.size.max_vol

    return unless picture.size > max_vol.megabytes

    errors.add(:picture, t("error_explanation.too_big_file"))
  end
end
