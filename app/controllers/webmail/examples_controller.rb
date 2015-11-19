# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class Webmail::ExamplesController < ApplicationController

  def recommendation
    recommendation = ExampleRecommendation.new(upcoming_limit: params[:upcoming], recent_limit: params[:recent])

    # get the email - assumes html only for now
    # we'll need to change this up for multipart
    mail = EventMailer.recommendation(recommendation: recommendation, cache_email: false)

    return render_mail(mail)
  end

  def reminder
    mail = EventMailer.reminder(learner: Learner.learnbot, event: Event.last, cache_email: false)
    return render_mail(mail)
  end

  def recording
    mail = EventMailer.recording(learner: Learner.learnbot, event: Event.last, cache_email: false)
    return render_mail(mail)
  end

  def activity
    mail = EventMailer.activity(learner: Learner.learnbot, event: Event.last, cache_email: false)
    return render_mail(mail)
  end

  def event_edit
    mail = EventMailer.event_edit(learner: Learner.learnbot, event: Event.last, cache_email: false)
    return render_mail(mail)
  end

  def event_canceled
    mail = EventMailer.event_canceled(learner: Learner.learnbot, event: Event.last, cache_email: false)
    return render_mail(mail)
  end

  def event_rescheduled
    mail = EventMailer.event_rescheduled(learner: Learner.learnbot, event: Event.last, cache_email: false)
    return render_mail(mail)
  end

  def event_location_changed
    mail = EventMailer.event_location_changed(learner: Learner.learnbot, event: Event.last, cache_email: false)
    return render_mail(mail)
  end

  def comment_reply
    mail = EventMailer.comment_reply(learner: Learner.learnbot, comment: Comment.last, cache_email: false)
    return render_mail(mail)
  end

  def inform_iastate_new
    mail = EventMailer.inform_iastate_new(event: Event.last, cache_email: false)
    return render_mail(mail)
  end

  def inform_iastate_update
    mail = EventMailer.inform_iastate_update(event: Event.last, cache_email: false)
    return render_mail(mail)
  end

  def inform_iastate_canceled
    mail = EventMailer.inform_iastate_canceled(event: Event.last, cache_email: false)
    return render_mail(mail)
  end

  def learner_retired
    mail = EventMailer.learner_retired(learner: Learner.last, cache_email: false)
    return render_mail(mail)
  end

  def registration
    mail = EventMailer.registration(registration: EventRegistration.last, cache_email: false)
    return render_mail(mail)
  end

  def registration_reminder
    mail = EventMailer.registration_reminder(registration: EventRegistration.last, cache_email: false)
    return render_mail(mail)
  end

  def mailtest
    mail = EventMailer.mailtest(learner: Learner.learnbot, cache_email: false)
    return render_mail(mail)
  end

  protected

  def render_mail(mail_message)
    # is this a multipart? then render the first html part by default, unless the text view is requested
    if(mail_message.multipart?)
      if(params[:view] == 'text')
        @wordwrap = (params[:wordwrap] and params[:wordwrap] == 'no')
        @mailbody = get_first_text_body(mail_message)
        render(:template => 'webmail/text_email',:layout => false)
      else
        # send it through the inline style processing
        inlined_content = InlineStyle.process(get_first_html_body(mail_message),ignore_linked_stylesheets: true)
        render(:text => inlined_content, :layout => false)
      end
    elsif(mail_message.mime_type == 'text/plain')
      @wordwrap = (params[:wordwrap] and params[:wordwrap] == 'no')
      @mailbody = get_first_text_body(mail_message)
      render(:template => 'webmail/text_email', :layout => false)
    elsif(mail_message.mime_type == 'text/html')
      # send it through the inline style processing
      inlined_content = InlineStyle.process(get_first_html_body(mail_message),ignore_linked_stylesheets: true)
      render(:text => inlined_content, :layout => false)
    else # wtf?
      render(template: 'webmail/missing_view')
    end
  end

  # PLEASE NOTE: - these are built around the assumption of two part emails, one part html and one part text
  # these routines will need to be redesigned if images are ever attached, or there are additional parts
  def get_first_html_body(mail_message)
    if(!mail_message.multipart?)
      if(mail_message.mime_type == 'text/html')
        return mail_message.body.to_s
      else
        return ''
      end
    else
      mail_message.parts.each do |part|
        if(part.mime_type == 'text/html')
          return part.body.to_s
        end
      end
    end
  end

  def get_first_text_body(mail_message)
    if(!mail_message.multipart?)
      if(mail_message.mime_type == 'text/plain')
        return mail_message.body.to_s
      else
        return ''
      end
    else
      mail_message.parts.each do |part|
        if(part.mime_type == 'text/plain')
          return part.body.to_s
        end
      end
    end
  end

end
