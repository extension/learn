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
      return_string << "<strong class='rating_count'>+#{positive_ratings_count}</strong>"
      return_string << "<div class='rating_explanation'>#{positive_ratings_count} person up-voted this</div>"
      return return_string.html_safe
    else
      return_string << "<strong class='rating_explanation none_yet'>Be the first to up-vote this</strong>"
      return return_string.html_safe
    end
  end
  
  def get_avatar(learner, image_size = :medium, portfolio_link = false, event_type = nil)
    case image_size
        when :medium    then image_size_in_px = "100x100"
        when :thumb     then image_size_in_px = "50x50"
    end
    return_string = ''
    privacy_needed = false
    
    # if the current learner is looking at themselves, show the avatar and leave privacy_needed at false
    if learner.id != current_learner.id 
      if event_type.class == Array
        event_type.each do |type_of_event|
          if learner.send("public_#{type_of_event.downcase}_events?") == false
            privacy_needed = true
            break
          end
        end
      else
        privacy_needed = true if (event_type.present?) && (learner.send("public_#{event_type.downcase}_events?") == false)  
      end
    end
    
    if learner.avatar.present? && privacy_needed == false
      return_string = image_tag(learner.avatar_url(image_size), :class => 'avatar')
    else 
      if privacy_needed == false
        return_string = image_tag("avatar_placeholder.png", :class => 'avatar', :size => image_size_in_px)
      else
        return_string = image_tag("avatar_placeholder.png", :class => 'avatar', :size => image_size_in_px, :title => 'private profile')
      end
    end
    
    if portfolio_link == :link_it && current_learner && privacy_needed == false 
      return_string = link_to(return_string, portfolio_learner_path(learner.id), :title => learner.name)
    end
    return return_string.html_safe
  end
  
  def link_to_learner(learner, event_type = nil)
    privacy_needed = false
    
    # if the current learner is looking at themselves, show the avatar and leave privacy_needed at false
    if learner.id != current_learner.id 
      if event_type.class == Array
        event_type.each do |type_of_event|
          if learner.send("public_#{type_of_event.downcase}_events?") == false
            privacy_needed = true
            break
          end
        end
      else
        privacy_needed = true if (event_type.present?) && (learner.send("public_#{event_type.downcase}_events?") == false)  
      end
    end
    
    if current_learner && privacy_needed == false
      return link_to(learner.name, portfolio_learner_path(learner.id)).html_safe
    elsif privacy_needed == true
      return 'private profile'
    else
      return learner.name
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
