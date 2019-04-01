OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, '743851213377-drqnro3emej8gimaki593a02dg3ups9h.apps.googleusercontent.com', 'DfXd8rxVphSnQto3XQp2H2Kv', {client_options: {ssl: {ca_file: Rails.root.join("cacert.pem").to_s}}}
end