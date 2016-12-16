class ApplicationController < ActionController::Base
  helper Openseadragon::OpenseadragonHelper
  # Adds a few additional behaviors into the application controller 
  include Blacklight::Controller
  include Hydra::Controller::ControllerBehavior

  # Adds CurationConcerns behaviors to the application controller.
  include CurationConcerns::ApplicationControllerBehavior  
  # Adds Sufia behaviors into the application controller 
  include Sufia::Controller

  # Behavior for devise.  Use remote user field in http header for auth.
  include Behaviors::HttpHeaderAuthenticatableBehavior

  include CurationConcerns::ThemedLayoutController
  layout 'sufia-one-column'


  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :clear_session_user

  # From PSU's ScholarSphere
  # Clears any user session and authorization information by:
  #   * ensuring the user will be logged out if REMOTE_USER is not set
  def clear_session_user
    return nil_request if request.nil?
    search = session[:search].dup if session[:search]
    request.env['warden'].logout unless user_logged_in?
    session[:search] = search
  end

  def user_logged_in?
    user_signed_in? && ( valid_user?(request.headers) || Rails.env.test?)
  end

  def sso_logout
    redirect_to Sufia::Engine.config.logout_prefix + logout_now_url
  end

  def sso_auto_logout
    Rails.logger.debug "[AUTHN] sso_auto_logout: #{current_user.try(:email) || '(no user)'}"
    sign_out(:user)
    cookies.delete("cosign-" + Sufia::Engine.config.hostname,
                   domain: Sufia::Engine.config.hostname, secure: true)
    session.destroy
    flash.clear
  end

  Warden::Manager.after_authentication do |user, auth, opts|
    Rails.logger.debug "[AUTHN] Warden after_authentication (clearing flash): #{user}"
    auth.request.flash.clear
  end

end
