module SimpleOauthAuthentication
  module ControllerMethods
    module Logins


      #This method handles the second and last part of the OAuth authentication
      #procedure. Once the user has approved access to his resources, the provider
      #redirects him back here to be authenticated with your system.
      #
      #Note that when reaching this method, you can get the access token for the
      #user's resources using the oauth_access_token method.
      def complete_oauth_login
        raise NotImplementedError, "You must define what 'complete oauth login' means"
      end


    private

      #Performs the initial step of the authentication. What happens is a request token
      #is retrieved from the provider and the user gets redirected to the provider to
      #authorize that token. Once the user has done this the provider will redirect him
      #back to oauth_callback_url, which by default is the complete_oauth_login method.
      def oauth_authentication
        redirect_to oauth_request_token.authorize_url
      end

      #Is this a "confirm" request? I.e. was the user redirected here by the provider
      #after authorizing access to his data?
      def oauth_confirm?
        oauth_verifier.present?
      end

      #Returns an OAuth::Consumer using the oauth_consumer_key and oauth_consumer_secret
      #for the provider defined in oauth_site
      def oauth_consumer
        @oauth_consumer ||= OAuth::Consumer.new(oauth_consumer_key, oauth_consumer_secret, oauth_consumer_parameters)
      end

      #The access token is used to access the user's resources from the provider. This is
      #usually only available in the second part of the auth procedure, when the provider
      #returns a "verifier" which can be used to exchange the request token for an access
      #token.
      def oauth_access_token
        @oauth_access_token ||= oauth_request_token.get_access_token({:oauth_verifier => oauth_verifier}, oauth_access_token_parameters)
      end

      #Set the OAuth request token. Returns token. Also saves the token and
      #secret in the session for later usage.
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
          oauth_consumer.get_request_token({:oauth_callback => oauth_callback_url}, oauth_request_token_parameters)
        end
      end


      #Parameters used when creating the OAuth::Consumer. If the provider doesn't
      #support automatic discover of endpoint URLs you probably want to add those
      #here.
      def oauth_consumer_parameters
        {:site => oauth_site}
      end

      #Parameters sent to the provider when asking for a request token.
      def oauth_request_token_parameters
        {}
      end

      #Parameters sent to the provider when asking for an access token.
      def oauth_access_token_parameters
        {}
      end

      #The "verifier" is sent back by the provider when a user approves access.
      #This method by default just plucks it out of the params.
      def oauth_verifier
        params[:oauth_verifier]
      end

      #The OAuth provider. Should return a string like "http://twitter.com"
      def oauth_site
        raise NotImplementedError, "Define the URL to the OAuth site you want to authenticate with"
      end

      #Which URL the provider should redirect the user to after approving access.
      #The default URL resolves to the complete_oauth_login action.
      def oauth_callback_url
        complete_oauth_login_url
      end

      #The OAuth consumer key is a site-specific key for each consumer
      #(=your site) that needs to access it. By default this gets looked up
      #using the I18n key simple_oauth_authentication.consumer_key
      #
      #TODO: Actually, this is pretty stupid. Change it.
      def oauth_consumer_key
        I18n.t('simple_oauth_authentication.consumer_key')
      end

      #The OAuth consumer secret is a site-specific "secret" which goes
      #along with the consumer key for each consumer. By default this gets
      #looked up using the I18n key simple_oauth_authentication.consumer_secret
      def oauth_consumer_secret
        I18n.t('simple_oauth_authentication.consumer_secret')
      end


    end
  end
end
