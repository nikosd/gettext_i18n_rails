# See Rails 3.0.4 bug https://rails.lighthouseapp.com/projects/8994/tickets/6393
require 'active_support/core_ext/module/deprecation'

class ActionController::Base
  def set_gettext_locale
    requested_locale = params[:locale] || session[:locale] || cookies[:locale] ||  request.env['HTTP_ACCEPT_LANGUAGE']
    session[:locale] = FastGettext.set_locale(requested_locale)
  end
end
