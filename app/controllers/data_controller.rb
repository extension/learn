# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file
require 'csv'

class DataController < ApplicationController
  before_filter :signin_required
  before_filter :require_admin, only: [:presenters, :recent_recommendations, :projected_recommendations, :recommended_event, :activity ]

  helper_method :sort_column, :sort_direction

  def overview
  end

  def activity
    @activity = ActivityLog.event_activity_records.order("created_at DESC")
    @activity = @activity.page(params[:page])
  end

  def events
    parse_dates
    parse_tag_tokens # sets @tag_token_names (hash of id/name)

    if(!params[:download].nil? and params[:download] == 'csv')
      if !params[:tag_tokens].blank?
        @events = Event.date_filtered(@start_date,@end_date).tagged_with_id(params[:tag_tokens]).order("session_start ASC")
        returndata = "Event Statistics for #{@start_date} - #{@end_date}\n"
        returndata += "Data filtered by tags: #{@tag_token_names.map{|h| h[:name]}.join('; ')}\n"
        returndata += "Please note: Event Date/Time is relative to your specified timezone: #{current_learner.time_zone.html_safe}\n\n"
        returndata += events_csv(@events)
        send_data(returndata,
          :type => 'text/csv; charset=utf-8; header=present',
          :disposition => "attachment; filename=event_statistics.csv")
      else
        @events = Event.date_filtered(@start_date,@end_date).includes([:tags, :presenters]).order("session_start ASC")
        returndata = "Event Statistics for #{@start_date} - #{@end_date}\n"
        returndata += "Please note: Event Date/Time is relative to your specified timezone: #{current_learner.time_zone.html_safe}\n\n"
        returndata += events_csv(@events)
        send_data(returndata,
          :type => 'text/csv; charset=utf-8; header=present',
          :disposition => "attachment; filename=event_statistics.csv")
      end
    elsif !params[:tag_tokens].blank?
      @events = Event.date_filtered(@start_date,@end_date).tagged_with_id(params[:tag_tokens]).order(sort_column + " " + sort_direction).page(params[:page])
    else
      @events = Event.date_filtered(@start_date,@end_date).order(sort_column + " " + sort_direction).page(params[:page])
    end

  end

  def zoom_webinars
    parse_dates
    if(!params[:download].nil? and params[:download] == 'csv')
      @events = Event.active.zoom_webinars.date_filtered(@start_date,@end_date).includes([:tags, :presenters]).order("session_start ASC")
      returndata = "Zoom Webinar Event Statistics for #{@start_date} - #{@end_date}\n"
      returndata += "Please note: Event Date/Time is relative to your specified timezone: #{current_learner.time_zone.html_safe}\n\n"
      returndata += events_csv(@events)
      send_data(returndata,
        :type => 'text/csv; charset=utf-8; header=present',
        :disposition => "attachment; filename=event_statistics.csv")
    else
      @events = Event.active.zoom_webinars.date_filtered(@start_date,@end_date).order(sort_column + " " + sort_direction).page(params[:page])
    end
  end


  def tags
    @tags = Tag.where("name like ?", "%#{params[:q]}%")

    respond_to do |format|
      format.html
      format.json { render :json => @tags.map(&:attributes) }
    end
  end

  def presenters
    parse_dates
    @presenter_list = PresenterConnection.event_date_filtered(@start_date,@end_date).group(:learner).count
  end

  protected

  def parse_dates
    begin
      @start_date = Date.parse(params[:start_date]).strftime('%Y-%m-%d')
    rescue
      @start_date = (Time.zone.now - 1.month).strftime('%Y-%m-%d')
    end

    begin
      @end_date = Date.parse(params[:end_date]).strftime('%Y-%m-%d')
    rescue
      @end_date = Time.zone.now.strftime('%Y-%m-%d')
    end
  end

  #This method was needed to return the tag name and id for token input. It reloads the tag name after a search is performed
  def parse_tag_tokens
    if !params[:tag_tokens].blank?
      tag_id_array = params[:tag_tokens].chomp.split(',')
      @tag_token_names = tag_id_array.collect{|tag| {id: tag, name: Tag.find(tag).name}}
    end
  end

  def events_csv(events)
  CSV.generate do |csv|
    headers = []
    headers << 'Date/Time'
    headers << 'Creator'
    headers << 'Canceled'
    headers << 'Expired'
    headers << 'Presenters'
    headers << 'Title'
    headers << 'Tags'
    headers << 'URL'
    headers << 'Audience'
    headers << 'Extension Zoom Webinar'
    headers << 'Recording'
    headers << 'Length'
    headers << 'Evaluation Link'
    headers << 'Followers'
    headers << 'Attendees'
    headers << 'Viewers'
    headers << 'Zoom Registrants'
    headers << 'Zoom eXtension Registrants'
    headers << 'Zoom Attendees'
    headers << 'Zoom eXtension Attendees'
    headers << 'Materials'
    csv << headers
    events.each do |event|
      row = []
      row <<  event.session_start.strftime("%Y-%m-%d %H:%M:%S")
      row << ((event.creator.blank? ? 'Unknown' : event.creator.name))
      row << ((event.is_canceled?) ? "canceled" : "")
      row << ((event.is_expired?) ? "expired" : "")
      row << event.presenters.collect{|learner| learner.name}.join('; ')
      row << event.title
      row << event.tags.collect{|tag| tag.name}.join('; ')
      row << event_url(event)
      row << event.primary_audience_label
      row << (event.is_extension_webinar? ? 'Yes' : 'No')
      row << ((event.has_recording?) ? event.recording : "n/a")
      row << event.session_length
      row << event.evaluation_link
      row << event.followers_count
      row << event.attendees_count
      row << event.viewers_count
      if(event.is_extension_webinar?)
        if event.zoom_webinar_status != Event::WEBINAR_STATUS_OK
          row << event.extension_webinar_status_invalid_reason
          row << '-'
          row << '-'
          row << '-'
        else
          connection_counts = event.zoom_webinar.connection_counts
          row << connection_counts[:registered][:total]
          row << connection_counts[:registered][:extension_account]
          row << connection_counts[:attended][:total]
          row << connection_counts[:attended][:extension_account]
        end
      else
        row << 'n/a'
        row << 'n/a'
        row << 'n/a'
        row << 'n/a'
      end

      row << event.material_links.map(&:reference_link).join(" ")
      csv << row
    end
  end
end

  private

  def sort_column
    params[:sort] || "session_start"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
end
