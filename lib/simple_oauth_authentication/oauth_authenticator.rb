module SimpleAuthentication

  class OauthAuthenticator < Authenticator

    def authentication_possible?
      true
    end

    def authenticate
      controller.send :oauth_authentication

      :ok
    end

  end

end
