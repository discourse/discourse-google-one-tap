# frozen_string_literal: true

class GoogleOneTapAuthenticator < Auth::ManagedAuthenticator

  def name
    "google_one_tap"
  end
  # To know if its enabled we would need to check the follwoing
  # 1. Google oauth2 is enabeld (since we will inhrint cleint id and secππret form it)
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
    omniauth.provider OmniAuth::Strategies::GoogleOneTap, setup: lambda { |env|
                                                                   strategy = env["omniauth.strategy"]}
  end
end
