module RelationshipsHelper
  def build_active_relationship
    current_user.active_relationships.build
  end

  def find_active_relationship id
    current_user.active_relationships.find_by followed_id: id
  end
end
