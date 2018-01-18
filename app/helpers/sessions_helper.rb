module SessionsHelper
  def log_in user
    session[:user_id] = user.id
  end

  def remember user
    @current_user = user
    @current_user.remember
    cookies_permanent = cookies.permanent
    cookies_permanent.signed[:user_id] = @current_user.id
    cookies_permanent[:remember_token] = @current_user.remember_token
  end

  def forget user
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  def current_user
    if (session_uid = session[:user_id])
      @current_user ||= User.find_by(id: session_uid)
    elsif (cookies_uid = cookies.signed[:user_id])
      user = User.find_by(id: cookies_uid)
      if user && user.authenticate?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  def logged_in?
    current_user ? true : false
  end

  def log_out
    forget current_user
    session.delete :user_id
    @current_user = nil
  end

  def params_session
    params[:session]
  end
end
