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
    @will_cache_email = options[:cache_email].nil? ? true : options[:cache_email]
    
    if(!@learner.email.blank?)
      if(@will_cache_email)
        # create a cached mail object that can be used for "view this in a browser" within
        # the rendered email.
        @mailer_cache = MailerCache.create(learner: @learner, cacheable: @recommendation)
      end
      
      return_email = mail(to: @learner.email, subject: @subject)
      
      if(@mailer_cache)
        # now that we have the rendered email - update the cached mail object
        @mailer_cache.update_attribute(:markup, return_email.body.to_s)
      end
    end
    
    # the email if we got it
    return_email
  end
  
  def reminder(options = {})
    @event = options[:event]
    @subject = "Your Learn Event is Starting Soon"
    @learner = options[:learner]  
    @will_cache_email = options[:cache_email].nil? ? true : options[:cache_email]
    
    if(!@learner.email.blank?)
      if(@will_cache_email)
        # create a cached mail object that can be used for "view this in a browser" within
        # the rendered email.
        @mailer_cache = MailerCache.create(learner: @learner, cacheable: @event)
      end
      
      return_email = mail(to: @learner.email, subject: @subject)
      
      if(@mailer_cache)
        # now that we have the rendered email - update the cached mail object
        @mailer_cache.update_attribute(:markup, return_email.body.to_s)
      end
    end
    
    # the email if we got it
    return_email
  end
  
  def recording(options = {})
    @event = options[:event]
    @subject = "A New Learn Recording is Available"
    @learner = options[:learner]  
    @will_cache_email = options[:cache_email].nil? ? true : options[:cache_email]
    
    if(!@learner.email.blank?)
      if(@will_cache_email)
        # create a cached mail object that can be used for "view this in a browser" within
        # the rendered email.
        @mailer_cache = MailerCache.create(learner: @learner, cacheable: @event)
      end
      
      return_email = mail(to: @learner.email, subject: @subject)
      
      if(@mailer_cache)
        # now that we have the rendered email - update the cached mail object
        @mailer_cache.update_attribute(:markup, return_email.body.to_s)
      end
    end
    
    # the email if we got it
    return_email
  end
  
  def activity(options = {})
    @event = options[:event]
    @subject = "There's New Activity on One of Your Learn Events"
    @learner = options[:learner]  
    @will_cache_email = options[:cache_email].nil? ? true : options[:cache_email]
    
    if(!@learner.email.blank?)
      if(@will_cache_email)
        # create a cached mail object that can be used for "view this in a browser" within
        # the rendered email.
        @mailer_cache = MailerCache.create(learner: @learner, cacheable: @event)
      end
      
      return_email = mail(to: @learner.email, subject: @subject)
      
      if(@mailer_cache)
        # now that we have the rendered email - update the cached mail object
        @mailer_cache.update_attribute(:markup, return_email.body.to_s)
      end
    end
    
    # the email if we got it
    return_email
  end

end
