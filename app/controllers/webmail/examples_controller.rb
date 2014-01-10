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
  
  def mailtest
    mail = EventMailer.mailtest(learner: Learner.learnbot, cache_email: false)
    return render_mail(mail)
  end

  protected
  
  def render_mail(mail)
    # send it through the inline style processing
    inlined_content = InlineStyle.process(mail.body.to_s,ignore_linked_stylesheets: true)
    render(:text => inlined_content, :layout => false)
  end
  
end