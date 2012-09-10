Airbrake.configure do |config|
		 config.api_key		 	= Settings.airbrake_api_key
		 config.host				= 'apperrors.extension.org'
		 config.port				= 80
		 config.secure			= config.port == 443
	 end
