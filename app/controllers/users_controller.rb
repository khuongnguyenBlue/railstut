class UsersController < ApplicationController
  attr_reader :user

  before_action :load_gender_options, only: %i(new create edit update)
  before_action :logged_in_user, only: %i(index edit update destroy)
  before_action :find_user, only: %i(show edit update destroy)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: :destroy

  def index
    @users = User.activated.paginate page: params[:page]
  end

  def new
    @user = User.new
  end

  def show
    return if user.activated?

    redirect_with_flash :danger, t("message.type.danger.user_not_active"), root_url
  end

  def create
    @user = User.new user_params
    if user.save
      user.send_activation_email
      redirect_with_flash :info, t("message.type.info.activate_by_email"), root_url
    else
      render :new
    end
  end

  def edit; end

  def update
    if user.update_attributes user_params
      redirect_with_flash :success, t("message.type.success.update_prof"), user
    else
      render :edit
    end
  end

  def destroy
    user.destroy
    redirect_with_flash :success, t("message.type.success.delete_user"), users_url
  end

  private

  def user_params
    params.require(:user).permit :name, :email, :password, :password_confirmation,
      :age, :gender
  end

  def load_gender_options
    @gender_options = User.sexes.map do |key, value|
      [I18n.t("users.sex.#{key}"), value]
    end
  end

  def logged_in_user
    return if logged_in?

    store_location
    redirect_with_flash :danger, t("message.type.danger.login_first"), login_url
  end

  def correct_user
    redirect_to root_url unless user.current_user? current_user
  end

  def admin_user
    redirect_to root_url unless current_user.admin?
  end

  def find_user
    @user = User.find_by id: params[:id]

    return if user

    redirect_with_flash :warning, t("message.type.warning.user_not_found"), root_url
  end
end
