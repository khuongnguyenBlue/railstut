class FollowersController < ApplicationController
  before_action :logged_in_user

  def index
    title = t "followers.title"
    user = User.find params[:id]
    users = user.followers.paginate page: params[:page]
    render "users/_show_follow", locals: {title: title, user: user, users: users}
  end
end
