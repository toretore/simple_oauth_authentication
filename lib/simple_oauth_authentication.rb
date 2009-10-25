require "oauth"
require "simple_authentication"
require "simple_oauth_authentication/oauth_authenticator"
require "simple_oauth_authentication/controller_methods"

SimpleAuthentication::ControllerMethods::Logins.send(:include, SimpleOauthAuthentication::ControllerMethods::Logins)
I18n.load_path.unshift(File.join(File.dirname(__FILE__), '..', 'config', 'locales', 'simple_oauth_authentication.yml'))
