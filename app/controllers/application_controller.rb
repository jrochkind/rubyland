class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  # just a simple thing to keep google and such away before
  # we've released.
  if ENV['DEMO_PASSWORD']
    before_action :protected_demo_authentication
  end

  protected

  def protected_demo_authentication
    auth = authenticate_with_http_basic do |u, p|
      p == ENV['DEMO_PASSWORD']
    end
    if !auth
      request_http_basic_authentication
    end
  end

end
