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
    recommendation = ExampleRecommendation.new(upcoming_limit: params[:upcoming], recent_limit: params[:recent])
        
    # get the email - assumes html only for now
    # we'll need to change this up for multipart
    mail = EventMailer.recommendation(recommendation: recommendation, cache_email: false)
    
    # send it through the inline style processing
    inlined_content = InlineStyle.process(mail.body.to_s,ignore_linked_stylesheets: true)

    render(:text => inlined_content, :layout => false)
  end
  
  def logo
    logo_filename = Rails.root.join('public', 'email', 'logo_small.png')
    if(mailer_cache = MailerCache.find_by_id(params[:mailer_cache_id]))
      ActivityLog.log_email_open(mailer_cache,{referer: request.env['HTTP_REFERER'], useragent: request.env['HTTP_USER_AGENT']})
    end
    
    respond_to do |format|
      format.png  { send_file(logo_filename, :type  => 'image/png', :disposition => 'inline') }
    end
  end
  
end
