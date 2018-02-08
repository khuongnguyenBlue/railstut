class PasswordResetsController < ApplicationController
  attr_reader :user

  before_action :find_user, only: %i(create edit update)
  before_action :validate_password_reset, only: %i(edit update)

  def new; end

  def create
    user.create_reset_digest
    UserMailer.password_reset(user).deliver_now
    redirect_with_flash :info, t("message.type.info.passwd_reset_sent"), root_url
  end

  def edit; end

  def update
    if params[:user][:password].empty?
      user.errors.add :password, t("error_explanation.empty")
    elsif user.update_attributes user_params
      log_in user
      return redirect_with_flash :success, t("message.type.success.password_reset"), user
    end
    render :edit
  end

  private

  def user_params
    params.require(:user).permit :password, :password_confirmation
  end

  def find_user
    @user = User.find_by email: params[:email].downcase

    return if user

    flash.now[:danger] = t "message.type.danger.email_not_found"
    render :new
  end

  def validate_password_reset
    redirect_to root_url unless user && user.activated? &&
                                user.authenticate?(:reset, params[:id])

    return unless user.password_reset_expired?

    redirect_with_flash :danger, t("message.type.danger.expired_reset_link"),
      new_password_reset_url
  end
end
