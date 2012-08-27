# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

module EventsHelper
  
  def is_boolean_answer_checked?(question,answer_value)
    if(!current_learner)
      false
    elsif(!(value = question.answer_value_for_learner_and_response(learner: current_learner)))
      false
    else
      value == answer_value
    end
  end
  
  
  def is_multivote_answer_checked?(question,response)
    if(!current_learner)
      false
    elsif(!(value = question.answer_value_for_learner_and_response(learner: current_learner, response: response)))
      false
    else
      # should always be true
      value == 1
    end
  end
  
  # we don't display comments from those who are blocked, and we also don't show the children of those comments, 
  # we're getting the count of just the comments that are shown.
  def get_filtered_comment_count(event)
    invisible_comments = event.comments.joins(:learner).where("learners.is_blocked = true")

    invisible_descendant_count = 0
    invisible_comments.each do |comment|
      invisible_descendant_count += comment.descendants.count
    end
    return event.comments.count - (invisible_comments.count + invisible_descendant_count)
  end
  
  # we don't display comments from those who are blocked, and we also don't show the children of those comments, 
  # we're getting the commentators (learners) of just those comments that are shown.
  def get_filtered_commentators(event)
    invisible_comments = event.comments.joins(:learner).where("learners.is_blocked = true")
    invisible_commenter_ids = invisible_comments.map{|c| c.learner_id}
    visible_commenter_ids = event.commentators.map{|l| l.id}
    
    invisible_comments.each do |comment|
      invisible_commenter_ids.concat(comment.descendants.map{|descendant| descendant.learner_id})
    end
    
    invisible_commenter_ids = invisible_commenter_ids - visible_commenter_ids
    
    if invisible_commenter_ids.length > 0
       event.commentators.where("learners.id NOT IN (#{invisible_commenter_ids.join(',')})")
    else
      return event.commentators
    end
  end
  
  def scale_value(question)
    if(!current_learner)
      nil
    else
      question.answer_value_for_learner_and_response(learner: current_learner)
    end
  end
  
  def multivote_scale_value(question,response)
    if(!current_learner)
      nil
    else
      question.answer_value_for_learner_and_response(learner: current_learner, response: response)
    end
  end
  
  
  def jqplot_bargraph_data(question)
    question.answer_data.map{|(label,value)| value}.to_json.html_safe
  end
  
  def jqplot_bargraph_xaxis_labels(question)
     (question.range_start..question.range_end).to_a.map{|i|i.to_s}.to_json.html_safe
  end
  
  def jqplot_piegraph_data(question)
    question.answer_data.to_json.html_safe
  end
  
  def display_presenters(presenters)
    if current_learner
      presenters.collect{|learner| link_to learner.name, portfolio_learner_path(learner)}.join(', ').html_safe
    else
      presenters.collect{|learner| learner.name}.join(', ')
    end
  end
  
  def display_tags(tags)
    tags.collect{|tag| link_to_tag(tag)}.join(' ').html_safe
  end
  
  def convert_to_rfc3339(time_to_convert)
    time_to_convert.utc.xmlschema
  end
  
end
