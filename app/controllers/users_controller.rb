class UsersController < ApplicationController
  attr_reader :user

  def new
    @user = User.new
    @gender_options = load_gender_options
  end

  def show
    @user = User.find params[:id]
  rescue ActiveRecord::RecordNotFound
    flash[:warning] = t "message.type.warning.user_not_found"
    redirect_to root_url
  end

  def create
    @user = User.new user_params
    if user.save
      flash[:success] = t "message.type.success.signin"
      redirect_to user
    else
      render :new
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation,
      :age, :gender)
  end

  def load_gender_options
    User.sexes.map do |key, value|
      [I18n.t("users.sex.#{key}"), value]
    end
  end
end
