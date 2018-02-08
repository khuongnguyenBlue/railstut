class RelationshipsController < ApplicationController
  attr_reader :user

  before_action :logged_in_user

  def create
    @user = User.find params[:followed_id]
    current_user.follow user
    ajax_respond
  end

  def destroy
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow user
    ajax_respond
  end

  private

  def ajax_respond
    respond_to do |format|
      format.html{redirect_to user}
      format.js
    end
  end
end
