# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class ZoomApiLog < ActiveRecord::Base
  serialize :additionaldata
  serialize :requestparams

  attr_accessible :webinar_id, :response_code, :endpoint, :requestparams, :additionaldata
  attr_accessible :json_error, :zoom_error, :zoom_error_code, :zoom_error_message

  def requestparams=(params_hash)
    params_hash.delete(:api_key)
    params_hash.delete(:api_secret)
    write_attribute(:requestparams,params_hash)
  end

  def additionaldata=(data)
    if(Settings.log_zoom_api_response)
      write_attribute(:additionaldata,data)
    end
  end

end
