# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class EventMailer < ActionMailer::Base
  default_url_options[:host] = Settings.urlwriter_host
  default from: "learn@extension.org"
  default bcc: "systemsmirror@extension.org"
  helper_method :ssl_root_url, :ssl_webmail_logo

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

  def registration(options = {})
    @registration = options[:registration]
    @event = Event.find(@registration.event_id)
    @subject = options[:subject] || 'Your Learn Registration'

    return_email = mail(to: @registration.email, subject: @subject)

    # the email if we got it
    return_email
  end

  def reminder(options = {})
    @event = options[:event]
    @subject = "Your Learn Event is Today"
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

  def comment_reply(options = {})
    @comment = options[:comment]
    @event = @comment.event
    @subject = "There's a New Reply to One of Your Learn Comments"
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

  def event_edit(options = {})
    @event = options[:event]
    @subject = "There's Been a Change to One of Your Learn Events"
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

  def event_canceled(options = {})
    @event = options[:event]
    @learner = options[:learner]
    @subject = "An eXtension Learn Event has been canceled"
    @creator = @event.creator
    @last_modified_by = @event.last_modifier
    @will_cache_email = options[:cache_email].nil? ? true : options[:cache_email]

    if(!@learner.email.blank?)
      if(@will_cache_email)
        # create a cached mail object that can be used for "view this in a browser" within
        # the rendered email.
        @mailer_cache = MailerCache.create(learner: @learner, cacheable: @event)
      end

      return_email = mail(from: @last_modified_by.email, to: @learner.email, subject: @subject)

      if(@mailer_cache)
        # now that we have the rendered email - update the cached mail object
        @mailer_cache.update_attribute(:markup, return_email.body.to_s)
      end
    end

    # the email if we got it
    return_email
  end

  def event_deleted(options = {})
    @event = options[:event]
    @learner = options[:learner]
    @subject = "An eXtension Learn Event has been deleted"
    @creator = @event.creator
    @last_modified_by = @event.last_modifier
    @will_cache_email = options[:cache_email].nil? ? true : options[:cache_email]

    if(!@learner.email.blank?)
      if(@will_cache_email)
        # create a cached mail object that can be used for "view this in a browser" within
        # the rendered email.
        @mailer_cache = MailerCache.create(learner: @learner, cacheable: @event)
      end

      return_email = mail(from: @last_modified_by.email, to: @learner.email, subject: @subject)

      if(@mailer_cache)
        # now that we have the rendered email - update the cached mail object
        @mailer_cache.update_attribute(:markup, return_email.body.to_s)
      end
    end

    # the email if we got it
    return_email
  end

  def event_rescheduled(options = {})
    @event = options[:event]
    @learner = options[:learner]
    @subject = "An eXtension Learn Event has been rescheduled"
    @creator = @event.creator
    @last_modified_by = @event.last_modifier
    @will_cache_email = options[:cache_email].nil? ? true : options[:cache_email]

    if(!@learner.email.blank?)
      if(@will_cache_email)
        # create a cached mail object that can be used for "view this in a browser" within
        # the rendered email.
        @mailer_cache = MailerCache.create(learner: @learner, cacheable: @event)
      end

      return_email = mail(from: @last_modified_by.email, to: @learner.email, subject: @subject)

      if(@mailer_cache)
        # now that we have the rendered email - update the cached mail object
        @mailer_cache.update_attribute(:markup, return_email.body.to_s)
      end
    end

    # the email if we got it
    return_email
  end

  def event_location_changed(options = {})
    @event = options[:event]
    @learner = options[:learner]
    @subject = "An eXtension Learn Event's Location has Changed"
    @creator = @event.creator
    @last_modified_by = @event.last_modifier
    @will_cache_email = options[:cache_email].nil? ? true : options[:cache_email]

    if(!@learner.email.blank?)
      if(@will_cache_email)
        # create a cached mail object that can be used for "view this in a browser" within
        # the rendered email.
        @mailer_cache = MailerCache.create(learner: @learner, cacheable: @event)
      end

      return_email = mail(from: @last_modified_by.email, to: @learner.email, subject: @subject)

      if(@mailer_cache)
        # now that we have the rendered email - update the cached mail object
        @mailer_cache.update_attribute(:markup, return_email.body.to_s)
      end
    end

    # the email if we got it
    return_email
  end

  def inform_iastate_new(options = {})
    @event = options[:event]
    @subject = "A new eXtension Learn Event has been created"
    @creator = @event.creator
    @presenter_emails = @event.presenters.map{|presenter| presenter.email}
    @cc_list = @presenter_emails.push(@creator.email).uniq
    @will_cache_email = options[:cache_email].nil? ? true : options[:cache_email]

    if(!@creator.email.blank?)
      if(@will_cache_email)
        # create a cached mail object that can be used for "view this in a browser" within
        # the rendered email.
        @mailer_cache = MailerCache.create(learner: @event.creator, cacheable: @event)
      end

      return_email = mail(from: @creator.email, to: Settings.iastate_support_email, cc: @cc_list, subject: @subject)

      if(@mailer_cache)
        # now that we have the rendered email - update the cached mail object
        @mailer_cache.update_attribute(:markup, return_email.body.to_s)
      end
    end

    # the email if we got it
    return_email
  end

  def inform_iastate_update(options = {})
    @event = options[:event]
    @subject = "An eXtension Learn Event has been rescheduled"
    @creator = @event.creator
    @presenter_emails = @event.presenters.map{|presenter| presenter.email}
    @last_modified_by = @event.last_modifier
    @cc_list = @presenter_emails.push(@creator.email).push(@last_modified_by.email).uniq
    @will_cache_email = options[:cache_email].nil? ? true : options[:cache_email]

    if(!@last_modified_by.email.blank?)
      if(@will_cache_email)
        # create a cached mail object that can be used for "view this in a browser" within
        # the rendered email.
        @mailer_cache = MailerCache.create(learner: @event.last_modifier, cacheable: @event)
      end

      return_email = mail(from: @last_modified_by.email, to: Settings.iastate_support_email, cc: @cc_list, subject: @subject)

      if(@mailer_cache)
        # now that we have the rendered email - update the cached mail object
        @mailer_cache.update_attribute(:markup, return_email.body.to_s)
      end
    end

    # the email if we got it
    return_email
  end

  def inform_iastate_canceled(options = {})
    @event = options[:event]
    @subject = "An eXtension Learn Event has been canceled"
    @creator = @event.creator
    @presenter_emails = @event.presenters.map{|presenter| presenter.email}
    @last_modified_by = @event.last_modifier
    @cc_list = @presenter_emails.push(@creator.email).push(@last_modified_by.email).uniq
    @will_cache_email = options[:cache_email].nil? ? true : options[:cache_email]

    if(!@last_modified_by.email.blank?)
      if(@will_cache_email)
        # create a cached mail object that can be used for "view this in a browser" within
        # the rendered email.
        @mailer_cache = MailerCache.create(learner: @event.last_modifier, cacheable: @event)
      end

      return_email = mail(from: @last_modified_by.email, to: Settings.iastate_support_email, cc: @cc_list, subject: @subject)

      if(@mailer_cache)
        # now that we have the rendered email - update the cached mail object
        @mailer_cache.update_attribute(:markup, return_email.body.to_s)
      end
    end

    # the email if we got it
    return_email
  end

  def learner_retired(options = {})
    @learner = options[:learner]
    @subject = "A Learner's account has been retired"
    @will_cache_email = options[:cache_email].nil? ? true : options[:cache_email]

    if(!@learner.email.blank?)
      if(@will_cache_email)
        # create a cached mail object that can be used for "view this in a browser" within
        # the rendered email.
        @mailer_cache = MailerCache.create(learner: @learner, cacheable: @event)
      end

      return_email = mail(to: Settings.engineering_list, subject: @subject)

      if(@mailer_cache)
        # now that we have the rendered email - update the cached mail object
        @mailer_cache.update_attribute(:markup, return_email.body.to_s)
      end
    end

    # the email if we got it
    return_email
  end

  def mailtest(options = {})
    @subject = "This is a test of the Learn Email System."
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

  def ssl_root_url
    if(Settings.app_location != 'localdev')
      root_url(protocol: 'https')
    else
      root_url
    end
  end

  def ssl_webmail_logo
    parameters = {mailer_cache_id: @mailer_cache.id, format: 'png'}
    if(Settings.app_location != 'localdev')
      webmail_logo_url(parameters.merge({protocol: 'https'}))
    else
      webmail_logo_url(parameters)
    end
  end

end
