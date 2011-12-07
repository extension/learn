# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class EventMailer < ActionMailer::Base
  default_url_options[:host] = Settings.urlwriter_host
  default from: "learn@extension.org"

  def recommendation(options = {})
    @recommendation = options[:recommendation]
    @subject = options[:subject] || 'Your Weekly Learn Recommendations'
    @learner = @recommendation.learner
    
    if(!@learner.email.blank?)
      # create a cached mail object that can be used for "view this in a browser" within
      # the rendered email.
      @mailer_cache = MailerCache.create(learner: @learner, cacheable: @recommendation)
      return_email = mail(to: @learner.email, subject: @subject)
      # now that we have the rendered email - update the cached mail object
      @mailer_cache.update_attribute(:markup, return_email.body.to_s)
    end
    
    # the email if we got it
    return_email
  end
  
  # method to render recommendation email without
  # caching, and in order to facilitate example options
  def example_recommendation(options = {})
    @recommendation = options[:recommendation]
    @subject = options[:subject] || 'Your Weekly Learn Recommendations'
    @learner = @recommendation.learner

    return_email = mail(to: @learner.email, subject: @subject) do |format|
      format.html {render "recommendation"}
    end
    return_email
  end
end
