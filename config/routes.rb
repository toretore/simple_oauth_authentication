ActionController::Routing::Routes.draw do |map|
  map.complete_oauth_login '/login/oauth/complete', :controller => "logins", :action => "complete_oauth_login"
end
