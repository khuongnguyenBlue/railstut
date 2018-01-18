class UsersController < ApplicationController
  attr_reader :user

  before_action :load_gender_options, only: %i(new create edit update)
  before_action :logged_in_user, only: %i(index edit update destroy)
  before_action :find_user, only: %i(show edit update destroy)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: :destroy

  def index
    @users = User.paginate page: params[:page]
  end

  def new
    @user = User.new
  end

  def show
  rescue ActiveRecord::RecordNotFound
    flash[:warning] = t "message.type.warning.user_not_found"
    redirect_to root_url
  end

  def create
    @user = User.new user_params
    if user.save
      log_in user
      flash[:success] = t "message.type.success.signin"
      redirect_to user
    else
      render :new
    end
  end

  def edit; end

  def update
    if user.update_attributes user_params
      flash[:success] = t "message.type.success.update_prof"
      redirect_to user
    else
      render :edit
    end
  end

  def destroy
    user.destroy
    flash[:success] = t "message.type.success.delete_user"
    redirect_to users_url
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation,
      :age, :gender)
  end

  def load_gender_options
    @gender_options = User.sexes.map do |key, value|
      [I18n.t("users.sex.#{key}"), value]
    end
  end

  def logged_in_user
    return if logged_in?
    store_location
    flash[:danger] = t "message.type.danger.login_first"
    redirect_to login_url
  end

  def correct_user
    redirect_to root_url unless user.current_user?
  end

  def admin_user
    redirect_to root_url unless current_user.admin?
  end

  def find_user
    @user = User.find_by id: params[:id]
  end
end
