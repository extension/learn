# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

module ApplicationHelper
  
  def format_text_for_display(content)
    return word_wrap(simple_format(auto_link(content, :all, :target => "_blank"))).html_safe 
  end
  
end
