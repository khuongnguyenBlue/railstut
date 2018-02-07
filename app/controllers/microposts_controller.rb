class MicropostsController < ApplicationController
  attr_reader :micropost

  before_action :logged_in_user, only: %i(create destroy)
  before_action :correct_user, only: :destroy

  def create
    @micropost = current_user.microposts.build micropost_params
    if micropost.save
      redirect_with_flash :success, t("message.type.success.create_micropost"), root_url
    else
      @feed_items = current_user.feed.paginate page: params[:page]
      render "static_pages/home"
    end
  end

  def destroy
    micropost.destroy
    redirect_with_flash :success, t("message.type.success.delete_micropost"),
      request.referer || root_url
  end

  private

  def micropost_params
    params.require(:micropost).permit :content, :picture
  end

  def correct_user
    @micropost = current_user.microposts.find_by id: params[:id]
    redirect_to root_url unless micropost
  end
end
