# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

module TagUtilities
  
  def set_tag(tag)
    if self.tags.collect{|t| Tag.normalizename(t.name)}.include?(Tag.normalizename(tag))
      return nil
    else 
      begin
        if(tag = Tag.find_or_create_by_name(Tag.normalizename(tag)))
          self.tags << tag
        end
      rescue
        return nil
      end  
      return tag
    end
  end
  
end