# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class MailerController < ApplicationController
  
  def recommendation
    if(current_learner)
      learner = current_learner
    else
      learner = Learner.learnbot
    end
    
    # get the email - assumes html only for now
    # we'll need to change this up for multipart
    mail = EventMailer.recommendation(learner)
    
    # send it through the inline style processing
    inlined_content = InlineStyle.process(mail.body.to_s,ignore_linked_stylesheets: true)

    render(:text => inlined_content, :layout => false)
  end
  
end
