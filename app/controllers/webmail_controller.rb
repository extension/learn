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

  def view
    if(mailer_cache = MailerCache.find_by_hashvalue(params[:hashvalue]))
      inlined_content = InlineStyle.process(mailer_cache.markup,ignore_linked_stylesheets: true)
      render(:text => inlined_content, :layout => false)
    else
      return render(template: "webmail/missing_view")
    end
  end

  def logo
    logo_filename = Rails.root.join('public', 'email', 'logo_small.png')
    respond_to do |format|
      format.png  { send_file(logo_filename, :type  => 'image/png', :disposition => 'inline') }
    end
  end

end
