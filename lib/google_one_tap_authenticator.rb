# frozen_string_literal: true

class GoogleOneTapAuthenticator < Auth::ManagedAuthenticator
  def name
    "google_one_tap"
  end

  # To know if it's enabled we would need to check the following
  # 1. Google oauth2 is enabeld (since we will inherit client id and secret form it)
  # 2. The plugin is enabled
  def enabled?
    SiteSetting.google_one_tap_enabled
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
