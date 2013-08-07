RedmineApp::Application.routes.draw do
  match 'account/login_by_rtx', :to => 'account#login_by_rtx', :as => 'signin_rtx', :via => [:get, :post]
end
