module WidgetsHelper

  def get_event_links_and_times(event_list)
    event_times_list = Array.new
    return_string = ''

    event_list.each do |e|
      event_time = e.session_start.strftime("%B %e")
      event_year = e.session_start.strftime("%Y")

      if event_time.present? && !event_times_list.include?(event_time)
        return_string += "<p class=\"learn-widget-event-date learn_widget_event_time\">#{event_time}<span class=\"event-year event_year\">, #{event_year}</span></p>"
        event_times_list << event_time
      end

      return_string += "<p class=\"learn-widget-event-title learn_widget_event_title\">#{link_to e.title, event_url(e.id)}</p>"
    end
    return return_string.html_safe
  end

end
