# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

module EventsHelper

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
    if(event.is_long_event?)
      end_minus_start = event.session_end.to_date - event.session_start.to_date
      "#{(end_minus_start+1).to_i} day event".html_safe
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
