GmailAnalyzer::Application.routes.draw do
  get "/emails/:username", :controller => "email", :action => "index"
end