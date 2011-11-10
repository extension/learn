# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

module ApplicationHelper
  
  def format_text_for_display(content)
    return word_wrap(simple_format(auto_link(content, :all, :target => "_blank"))).html_safe 
  end
  
  def formatted_votes(rated_object)
    positive_ratings_count = rated_object.ratings.positive.count
    return_string = ''
  
    if (positive_ratings_count > 0)
      return_string << "<strong class='formatted_votes'>+#{positive_ratings_count}</strong>"
      return_string << "<div id='rating_explanation'>Positive votes: #{positive_ratings_count}</div>"
      return return_string.html_safe
    else
      return "<strong class='formatted_votes'>No Ratings Yet</strong>".html_safe
    end
  end
  
  
  def link_to_learner(learner)
    link_to(learner.name, '#').html_safe
  end
  
  def link_to_tag(tag)
    link_to(tag.name, '#').html_safe
  end
end
