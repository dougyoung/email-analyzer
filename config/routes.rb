GmailAnalyzer::Application.routes.draw do
  get ':username', :controller => 'email', :action => 'index'
  get ':username/:grouping_threshold', :controller => 'email', :action => 'index'

  get '/enter_password', :controller => 'email', :action => 'enter_password', :as => :enter_password
end