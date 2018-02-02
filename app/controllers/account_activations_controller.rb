class AccountActivationsController < ApplicationController
  def edit
    user = User.find_by email: params[:email]
    if user && !user.activated? && user.authenticate?(:activation, params[:id])
      user.activate
      log_in user
      redirect_with_flash :success, t("message.type.success.acc_activate"), user
    else
      redirect_with_flash :danger, t("message.type.danger.activate_err"), root_url
    end
  end
end
