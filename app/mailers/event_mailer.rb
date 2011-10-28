# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class EventMailer < ActionMailer::Base
  default_url_options[:host] = Settings.urlwriter_host
  default from: "learn@extension.org"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifier.recommendation.subject
  #
  def recommendation(learner)
    @learner = learner
    
    if(!@learner.email.blank?)
      mail(to: @learner.email, subject: 'Testing')
    end
  end
end
