# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

module ConferencesHelper

  def display_room(room)
    if(!room.blank?)
      room.html_safe
    else
      'Not listed.'.html_safe
    end
  end


  def nav_li(time,index)
    (nav_is_active?(time,index) ? "<li class='active'>".html_safe : "<li>".html_safe)
  end

  def tab_pane_divclass(time,index)
    (nav_is_active?(time,index) ? "tab-pane active" : "tab-pane")
  end

  def nav_is_active?(time,index)
    if @datetime
      @datetime == time 
    else
      (index == 0)
    end
  end



end
