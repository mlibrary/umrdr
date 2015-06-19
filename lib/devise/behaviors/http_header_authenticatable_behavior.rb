# Default strategy for signing in a user, based on his email and password in the database.
module Behaviors
  module HttpHeaderAuthenticatableBehavior

    # Called if the user doesn't already have a rails session cookie
    def valid_user?(headers)
      !remote_user(headers).blank?
    end

    protected

    # Return demo_user in development, the remote user or nil otherwise
    def remote_user(headers)
      if Rails.env.development?
        'demo_user'
      elsif headers['HTTP_X_REMOTE_USER']
        headers['HTTP_X_REMOTE_USER']
      else
        nil
      end
    end
  end
end
