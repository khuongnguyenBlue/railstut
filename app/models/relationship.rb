class Relationship < ApplicationRecord
  belongs_to :follower, inverse_of: :active_relationships, class_name: User.name
  belongs_to :followed, inverse_of: :passive_relationships, class_name: User.name
  validates :follower, presence: true
  validates :followed, presence: true
end
