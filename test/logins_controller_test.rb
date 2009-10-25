require 'rubygems'
require 'test/unit'
require 'mocha'
require 'simple_openid_authentication/controller_methods'

class I18n
  def self.t(*a)
    ''
  end
end

class MockController
  attr_accessor :current_user, :authentication_failed_called, :authentication_successful_called
  include SimpleOAuthAuthentication::ControllerMethods::Logins
  def params
    @params ||= {}
  end
  def session
    @session ||= {}
  end
  def authentication_successful(*a)
    self.authentication_successful_called = true
  end
  def authentication_failed(*a)
    self.authentication_failed_called = true
  end
end

class User
  attr_accessor :url, :name, :email, :save_should_succeed, :awesome
  def initialize(url)
    self.url = url
  end
  def save
    save_should_succeed
  end
end

class LoginsControllerTest < Test::Unit::TestCase

  def setup
    @controller = MockController.new
  end

  #TODO: Add some tests when I figure out what to actually test.

end
