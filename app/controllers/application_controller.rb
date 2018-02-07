class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper

  before_action :set_locale

  private

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options
    {locale: I18n.locale}
  end

  def redirect_with_flash type, msg, url
    flash[type] = msg
    redirect_to url
  end

  def logged_in_user
    return if logged_in?
    store_location
    redirect_with_flash :danger, t("message.type.danger.login_first"), login_url
  end
end
