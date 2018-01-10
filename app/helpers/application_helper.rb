module ApplicationHelper
  def prefix_title
    content_for(:title) + " | " if content_for?(:title)
  end
end
