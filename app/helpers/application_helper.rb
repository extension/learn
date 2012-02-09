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
    
    ### determining whether privacy needs to be set ###
    
    privacy_on = false
    # if multiple event types are passed in such as a general connection to an event
    if event_type.class == Array
      event_type.each do |type_of_event|
        if learner.send("public_#{type_of_event.downcase}_events?") == false
          privacy_on = true
          break
        end
      end
    elsif event_type.present? && (learner.send("public_#{event_type.downcase}_events?") == false)  
      privacy_on = true
    else
      privacy_on = false
    end
    
    # if we're looking at ourselves
    # avatar will always be returned and it will always be linked
    if current_learner && (learner.id == current_learner.id)
      if learner.avatar.present? 
        return_string = image_tag(learner.avatar_url(image_size), :class => 'avatar')
        if privacy_on
          if portfolio_link == :link_it
            ### TODO: Do something here with linking ###
            return link_to(return_string, portfolio_learner_path(learner.id), :title => learner.name).html_safe
          end
        end
      # no avatar for learner
      else
        return_string = image_tag("avatar_placeholder.png", :class => 'avatar', :size => image_size_in_px)
        if privacy_on
          return link_to(return_string, portfolio_learner_path(learner.id), :title => learner.name).html_safe
        end
      end
    # conditions for privacy for everyone else   
    else
      if privacy_on
        return_string = image_tag("avatar_placeholder.png", :class => 'avatar', :size => image_size_in_px, :title => 'private profile')
      elsif learner.avatar.present?
        return_string = image_tag(learner.avatar_url(image_size), :class => 'avatar')
      else
        return_string = image_tag("avatar_placeholder.png", :class => 'avatar', :size => image_size_in_px, :title => learner.name)
      end
    end
    
    # determine what to do with linking based on privacy settings
    if portfolio_link == :link_it && current_learner && privacy_on == false 
      return_string = link_to(return_string, portfolio_learner_path(learner.id), :title => learner.name)
    end
    return return_string.html_safe
  end
  
  def link_to_learner(learner, event_type = nil)
    # determine whether privacy needs to be set
    if event_type.present? && (learner.send("public_#{event_type.downcase}_events?") == false)  
      privacy_on = true
    else
      privacy_on = false
    end
    
    # if we're looking at ourselves
    if current_learner && (learner.id == current_learner.id)
      if privacy_on
        return link_to("#{learner.name} (seen as private profile)", portfolio_learner_path(learner.id)).html_safe
      else
        return link_to(learner.name, portfolio_learner_path(learner.id)).html_safe
      end
    end
    
    # conditions for privacy for everyone else 
    if privacy_on
      return 'private profile'
    else
      if current_learner
        return link_to(learner.name, portfolio_learner_path(learner.id)).html_safe
      else
        return learner.name
      end
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
