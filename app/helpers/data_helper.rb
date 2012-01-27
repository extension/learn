# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

module DataHelper
  
  def activity_description(activity_type)
    case activity_type
    when 1
      description = "viewed"
    when 2
      description = "viewed from a reccomendation"
    when 3
      description = "viewed from a share"
    when 11
      description = "shared"
    when 21
      description = "answered a question"
    when 31
      description = "rated an event"
    when 32
      description = "rated a comment"
    when 41
      description = "commented"
    when 42
      description = "commented on a comment"
    when 50
      description = "connected"
    when 51
      description = "connected as presenter"
    when 52
      description = "bookmarked"
    when 53
      description = "attended"
    when 54
      description = "watched"
    else
      description = "not sure what activity occurred"
    end
  end
  
  def nav_item(path,label)
    list_item_class = current_page?(path) ? 'active' : ''
    "<li class='#{list_item_class}'>#{link_to(label,path)}</li>".html_safe
  end

  def event_recommended?(event,learner,score)
    reasons = []
    recommended = true
    if(score < Settings.minimum_recommendation_score)
      recommended = false
      reasons << "score < #{Settings.minimum_recommendation_score}"
    end
    
    if(event.learners.include?(learner) or event.presenters.include?(learner))
      recommended = false
      reasons << "already connected"
    end
    
    if(recommended)
      '<span class="label success">Yes</span>'.html_safe()
    else
      "<span class='label important'>No</span> (#{reasons.join(', ')})".html_safe()
    end
  end
  
  def recommended_event_viewed?(recommended_event)  
    if(recommended_event.viewed?)
      '<span class="label success">Yes</span>'.html_safe()
    else
      "<span class='label important'>No</span>".html_safe()
    end
  end
  
end