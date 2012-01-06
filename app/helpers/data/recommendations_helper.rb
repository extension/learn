# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

module Data::RecommendationsHelper

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