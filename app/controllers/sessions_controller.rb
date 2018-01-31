class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by email: params_session[:email].downcase
    if user && user.authenticate(params_session[:password])
      login_success user
    else
      login_fail
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end

  private

  def login_success user
    log_in user
    params_session[:remember_me] == "1" ? remember(user) : forget(user)
    redirect_back_or user
  end

  def login_fail
    flash.now[:danger] = t "message.type.danger.invalid_login"
    render :new
  end
end
