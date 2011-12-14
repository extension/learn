# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

module ApplicationHelper
  
  def format_text_for_display(content)
    return word_wrap(simple_format(auto_link(content, :all, :target => "_blank"))).html_safe 
  end
  
  def formatted_votes(rated_object, logged_in_learner)
    positive_ratings_count = rated_object.ratings.positive.count
    return_string = ''
  
    if (positive_ratings_count > 0)
      return_string << "<strong class='formatted_votes'>+#{positive_ratings_count}</strong>"
      return_string << "<div id='rating_explanation'>Positive votes: #{positive_ratings_count}</div>"
      return return_string.html_safe
    else
      return_string << "<strong class='formatted_votes'>No Ratings Yet</strong>"
      return return_string.html_safe
    end
  end
  
  
  def link_to_learner(learner)
    if current_learner
      link_to(learner.name, portfolio_learner_path(learner.id)).html_safe
    else
      learner.name
    end
  end
  
  def link_to_tag(tag)
    link_to(tag.name, event_tag_path(:tags => tag.name)).html_safe
  end
  
  def flash_notifications
    message = flash[:error] || flash[:notice] || flash[:warning]
    return_string = ''
    if message
      type = flash.keys[0].to_s
      return_string << '<div id="flash_notification" class="' + type + '"><p>' + message + '</p></div>'
      return return_string.html_safe
    end
  end
  
end
