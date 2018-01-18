module UsersHelper
  attr_reader :user

  def gravatar_for usr, option = {size: 80}
    @user = usr
    gravatar_id = Digest::MD5.hexdigest user.email.downcase
    size = option[:size]
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    image_tag gravatar_url, alt: user.name, class: "gravatar"
  end
end
