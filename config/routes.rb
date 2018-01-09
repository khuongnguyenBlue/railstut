Rails.application.routes.draw do
  scope "(:locale)", locale: /#{I18n.available_locales.join("|")}/ do
    root "static_pages#home"
    get "static_pages/home"
    get "static_pages/help"
    get "static_pages/about"
    get "static_pages/contact"
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
