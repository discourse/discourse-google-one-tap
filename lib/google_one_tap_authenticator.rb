# frozen_string_literal: true

class GoogleOneTapAuthenticator < Auth::ManagedAuthenticator
  def name
    "google_one_tap"
  end

  def enable_setting
    :google_one_tap_enabled
  end

  def required_settings
    %i[google_oauth2_client_id]
  end

  def can_revoke?
    false
  end

  def can_connect_existing_user?
    false
  end

  def register_middleware(omniauth)
    omniauth.provider(OmniAuth::Strategies::GoogleOneTap)
  end

  def primary_email_verified?(auth_token)
    true
  end
end
