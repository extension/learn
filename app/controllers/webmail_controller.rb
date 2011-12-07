# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class WebmailController < ApplicationController
  
  def recommendation
    if(mailer_cache = MailerCache.find_by_hashvalue(params[:hashvalue]))
      inlined_content = InlineStyle.process(mailer_cache.markup,ignore_linked_stylesheets: true)
      render(:text => inlined_content, :layout => false)
    else
      return render(template: "webmail/missing_recommendation")
    end
  end
  
  def example_recommendation
    recommendation = ExampleRecommendation.new
    
    # get the email - assumes html only for now
    # we'll need to change this up for multipart
    mail = EventMailer.example_recommendation(recommendation: recommendation)
    
    # send it through the inline style processing
    inlined_content = InlineStyle.process(mail.body.to_s,ignore_linked_stylesheets: true)

    render(:text => inlined_content, :layout => false)
  end
  
end
