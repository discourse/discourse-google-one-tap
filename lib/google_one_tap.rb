# frozen_string_literal: true

module OmniAuth
  module Strategies
    class GoogleOneTap
      class GoogleOneTapValidationError < StandardError; end
      class GoogleOneTapCSFRError < StandardError; end
      include OmniAuth::Strategy

      option :name , "google_one_tap"

      attr_accessor :access_token

      # There is no request phase for this strategy because it's implemented by the client-side google JS
      def request_phase
        raise Middleware::OmniauthBypassMiddleware::AuthenticatorDisabled.new("Not exists")
      end

      # These are called after authentication has succeeded (From Google side!).
      def callback_phase
        # We first check for CSRF and then validate the token.
        # Ref: https://developers.google.com/identity/gsi/web/guides/verify-google-id-token
        begin
         if check_csrf
           self.access_token = build_access_token # It builds and validate it!.
         end
         super
       rescue GoogleOneTapCSFRError => e
         fail!(:invalid_csrf_token, e)
       rescue GoogleOneTapValidationError => e
         fail!(:invalid_credentials, e)
        rescue GoogleIDToken::CertificateError => e
          fail!(:certificate_error, e)
       end
      end

      def transform_token_to_omniauth(payload, credential)
        auth_token = {
          provider: "google_one_tap",
          info: {
            name: payload["name"],
            email: payload["email"],
            email_verified: payload["email_verified"],
            first_name: payload["given_name"],
            last_name: payload["family_name"],
            image: payload["picture"],
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
          # Here we just transform the payload to what OmniAuth expects.
          transform_token_to_omniauth(payload, request.params["credential"])
        rescue GoogleIDToken::ValidationError => e
          raise GoogleOneTapValidationError.new "Validation Error"
        end
      end

      def check_csrf
        g_csrf_token = request.params["g_csrf_token"]
        begin
        if g_csrf_token.blank?
          raise GoogleOneTapCSFRError
        end
        g_csrf_cookie = request.cookies["g_csrf_token"]
        if g_csrf_cookie.blank?
          raise GoogleOneTapCSFRError
        end
        if g_csrf_cookie != g_csrf_token
          raise GoogleOneTapCSFRError
        end
        true
        rescue GoogleOneTapCSFRError => e
          raise GoogleOneTapCSFRError.new("Invlaid CSRF")
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
