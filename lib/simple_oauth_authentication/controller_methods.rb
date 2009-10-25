module SimpleOauthAuthentication
  module ControllerMethods
    module Logins


    private

      def oauth_authentication
        redirect_to oauth_request_token.authorize_url
      end

      #Is this a "confirm" request? I.e. was the user redirected here by the provider?
      def oauth_confirm?
        oauth_verifier.present?
      end

      #Returns an OAuth::Consumer using the oauth_consumer_key and oauth_consumer_secret for the provider
      #defined in oauth_site
      def oauth_consumer
        @oauth_consumer ||= OAuth::Consumer.new(oauth_consumer_key, oauth_consumer_secret, :site => oauth_site)
      end

      #
      def oauth_access_token
        @oauth_access_token ||= oauth_request_token.get_access_token(:oauth_verifier => oauth_verifier)
      end

      #Set the OAuth request token. Returns token.
      def oauth_request_token=(token)
        session[:oauth_token], session[:oauth_secret] = token.token, token.secret
        @oauth_request_token = token
      end

      #Returns the request token for the given provider. If this is the initial request, the token
      #is requested from the provider. If this is the second "confirm" request, the token is
      #reassembled using the token and secret stored in the session.
      def oauth_request_token
        return @oauth_request_token if @oauth_request_token

        #Returns the token after setting it
        self.oauth_request_token = if oauth_confirm?
          #If this is a "confirm authentication" request, recreate the req token from the token/secret stored in the initial request
          OAuth::RequestToken.new(oauth_consumer, session[:oauth_token], session[:oauth_secret])
        else
          #If this is the initial request, request a request token/secret which will be stored in the session
          oauth_consumer.get_request_token(:oauth_callback => oauth_callback_url)
        end
      end

      def oauth_verifier
        params[:oauth_verifier]
      end

      #The OAuth provider (like Twitter)
      def oauth_site
        "http://twitter.com"
      end

      #After getting a request token, the user gets redirected to the OAuth provider (like Twitter). The provider
      #then redirects the user back to this URL, which performs the actual authentication. Both the initial and
      #the second request use the same URL and are distinguished by the presence of the oauth_verifier parameter,
      #which is done in oauth_confirm?
      def oauth_callback_url
        complete_oauth_login_url
      end

      #The OAuth consumer key is a site-specific key for each consumer (=your site) that needs
      #to access it.
      def oauth_consumer_key
        I18n.t('simple_oauth_authentication.consumer_key')
        "yEFJlVqSOwQ8piPukGiD0w"
      end

      #The OAuth consumer secret is a site-specific "secret" which goes along with the consumer
      #key for each consumer.
      def oauth_consumer_secret
        I18n.t('simple_oauth_authentication.consumer_secret')
        "ldoX4YIcBsIcfC6MxtPzmJ3yD2pRAAAkvB4cppBp68"
      end


    end
  end
end
