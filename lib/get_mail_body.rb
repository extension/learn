# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

module GetMailBody

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
