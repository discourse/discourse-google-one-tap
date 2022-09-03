# frozen_string_literal: true

module OmniAuth
  module Strategies
    class GoogleOneTap
      class GoogleOneTapValidationError < StandardError; end
      class GoogleOneTapCSFRError < StandardError; end
      include OmniAuth::Strategy

      option :name , "google_one_tap"
      ALLOWED_ISSUERS = ['accounts.google.com', 'https://accounts.google.com'].freeze

      # This is wbhere you pass the options you would pass when
      # initializing your consumer from the OAuth gem.
      attr_accessor :access_token
      option :provider_ignores_state, true

      # We don't need this phase, Google one tap/idenentity framework dones't require it
      # This is why this plugin doesn't need client_secret. as well
      def request_phase
        raise NotImplementedError
      end

      # These are called after authentication has succeeded (From Google side!).
      def callback_phase
        # We first check for CSRF and then validate the token.
        # Ref: https://developers.google.com/identity/gsi/web/guides/verify-google-id-token
        if check_csrf
          self.access_token = build_access_token # It builds and validate it!.
        end
        super
      end
      def transformTokenToOmniauth(payload, credential)
        auth_token = {
          provider: "google_one_tap",
          info: {
            name: payload["name"],
            email: payload["email"],
            email_verified: payload["email_verified"], # This always true (Accordoing to Google)
            first_name: payload["given_name"],
            last_name: payload["family_name"],
            image: payload["picture"],
            id_token: payload["jti"],
            nickname: payload["name"].gsub(" ", "_")
        },
          uid: payload["sub"],
          extra: {
          raw_info: credential #This the Google id-token (don't confuse this credential with the optional hash value of OmniAuth)
        }

      }
      auth_token
      end

      def build_access_token
        #Here we check for the token
        #The library already does few checks
        #Ref: https://github.com/google/google-id-token/blob/v1.4.2/lib/google-id-token.rb
        validator = GoogleIDToken::Validator.new
        begin
          payload = validator.check(request.params["credential"], SiteSetting.google_oauth2_client_id)
          if !(ALLOWED_ISSUERS.include?(payload["iss"])) # This is a redundant check. Library already check for it
            raise GoogleIDToken::ValidationError, "Invalid issuer."
          end
          if payload["aud"] != SiteSetting.google_oauth2_client_id  # This is aalso redudant check, bceause the validator above already checks this.
            raise GoogleIDToken::ValidationError, "Invalid audience."
          end
          if payload["exp"] < Time.now.utc.to_i # Again also probably a redudant  check. I think "jwt" (which the library uses) already checks this.
            raise GoogleIDToken::ValidationError, "Token expired."
          end
          # Here we just transform the payload to what OmniAuth expects.
          transformTokenToOmniauth(payload, request.params["credential"])
        rescue GoogleIDToken::ValidationError => e
          raise GoogleOneTapValidationError.new "Validation Error: #{e.message}"
        end
      end

      def check_csrf
        g_csrf_token = request.params["g_csrf_token"]
        begin
        if g_csrf_token.blank?
          raise CSRFTokenVerifier::InvalidCSRFToken
        end
        g_csrf_cookie = request.cookies["g_csrf_token"]
        if g_csrf_cookie.blank?
          raise CSRFTokenVerifier::InvalidCSRFToken
        end
        if g_csrf_cookie != g_csrf_token
          raise CSRFTokenVerifier::InvalidCSRFToken
        end
        true
        rescue CSRFTokenVerifier::InvalidCSRFToken => e
          raise GoogleOneTapCSFRError.new "CSRF Error"
      end
      end

      def info
        @access_token[:info]
      end

      def extra
        @access_token[:extra]
      end

      def raw_info
        @access_token[:raw_info]
      end

      def uid
        @access_token[:uid]
      end
      def provider
        @access_token[:provider]
      end
    end
  end
end
