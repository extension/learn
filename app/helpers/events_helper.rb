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

  def is_multichoice_evalanswer_checked?(event,evalquestion,response)
    if(!current_learner)
      false
    else
      answer = evalquestion.answer_for_learner_and_event(current_learner,event)
      if(!answer)
        false
      elsif(answer.response == response)
        true
      else
        false
      end
    end
  end

  def learner_has_trigger_response?(event,evalquestion)
    if(!current_learner)
      false
    else
      answer = evalquestion.answer_for_learner_and_event(current_learner,event)
      if(!answer)
        false
      else
        evalquestion.is_trigger_response?(answer.response)
      end
    end
  end

  def evalquestion_secondary_response_for_event(evalquestion,event)
    if(answer = evalquestion.answer_for_learner_and_event(current_learner,event))
      answer.secondary_response
    else
      ''
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

  def add_to_cal_timestamp(time_to_convert)
    time_to_convert.utc.strftime('%Y%m%dT%H%M%SZ')
  end

  def audience_options
    Event::AUDIENCE_LABELS.except(Event::AUDIENCE_BLANK).invert.to_a
  end

  def display_non_extension_webinar_status_for_event(event)
    case event.zoom_webinar_status
    when Event::WEBINAR_STATUS_LOCATION_BLANK
      reason = "No location has been set for this event"
    when Event::WEBINAR_STATUS_LOCATION_NOT_URL
      reason = "Event location is not a URL"
    when Event::WEBINAR_STATUS_LOCATION_NOT_EXTENSION_ZOOM
      reason = "Event location not hosted by eXtension"
    when Event::WEBINAR_STATUS_LOCATION_NOT_WEBINAR_URL
      reason = "Event location is not a recognized eXtension webinar (may be using registration url)"
    else
      reason = ""
    end
    reason.html_safe
  end


  def display_extension_webinar_status_invalid_reason(event)
    case event.zoom_webinar_status
    when Event::WEBINAR_STATUS_NOT_RETRIEVED
      reason = "The data for this webinar has not been retrieved"
    when Event::WEBINAR_STATUS_IS_RECURRING
      reason = "This is a recurring webinar, attendance data is not available"
    when Event::WEBINAR_STATUS_RETRIEVAL_ERROR
      reason = "There was an error retrieving the webinar data"
    when Event::WEBINAR_STATUS_TEMPORARY_RETRIEVAL_ERROR
      reason = "There was a temporary error retrieving the webinar data"
    else
      reason = ""
    end
    reason.html_safe
  end

  def display_session_duration(event)
    if(event.session_length >= 1440)
      "#{event.session_length.divmod(1440)[0]} day event".html_safe
    elsif(event.session_length >= 480)
      "1 day event".html_safe
    elsif(event.session_length <= 120)
      "#{event.session_length} minute event".html_safe
    else
      (hours,minutes) = event.session_length.divmod(60)
      if(minutes == 0)
        "#{hours} hour event".html_safe
      else
        "#{hours} hour, #{minutes} minute event".html_safe
      end
    end
  end




end
