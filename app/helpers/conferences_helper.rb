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

end
