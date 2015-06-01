class AuthController < ApplicationController
  def splash
  end

  def login
    reset_shib_session
    redirect_to splash_path
  end

  def destroy
    reset_session
    return_to = '?logoutWithoutPrompt=1&Submit=yes, log me out&returnto=%s' % params[:target]
    return_to_encoded = ERB::Util::url_encode( request = return_to )
    redirect_this_to = Rails.application.config.shibboleth_logout_path + return_to_encoded
    redirect_to redirect_this_to
  end

  private

  def reset_shib_session
    reset_session
    session[:uid] = request.env['omniauth.auth'][:uid]
    session[:shib_session_id] = request.env['HTTP_SHIB_SESSION_ID']
  end
end
