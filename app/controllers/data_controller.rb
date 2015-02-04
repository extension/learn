# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file
require 'csv'

class DataController < ApplicationController
  before_filter :authenticate_learner!
  before_filter :require_admin, only: [:presenters, :recent_recommendations, :projected_recommendations, :recommended_event, :activity ]

  helper_method :sort_column, :sort_direction

  def overview
  end

  def activity
    @activity = ActivityLog.event_activity_records.order("created_at DESC")
    @activity = @activity.page(params[:page])
  end

  def blocked_activity
    learner_activity = LearnerActivity.blocking.order("created_at DESC")
    @activities = learner_activity.page(params[:page])
  end

  def events
    parse_dates
    parse_tag_tokens # sets @tag_token_names (hash of id/name)

    if(!params[:download].nil? and params[:download] == 'csv')

      if !params[:tag_tokens].blank?
        @events = Event.date_filtered(@start_date,@end_date).tagged_with_id(params[:tag_tokens]).order("session_start ASC")
        returndata = "Event Statistics for #{@start_date} – #{@end_date}\n"
        returndata += "Data filtered by tags: #{@tag_token_names.map{|h| h[:name]}.join('; ')}\n"
        returndata += "Please note: Event Date/Time is relative to your specified timezone: #{current_learner.time_zone.html_safe}\n\n"
        returndata += events_csv(@events)
        send_data(returndata,
          :type => 'text/csv; charset=utf-8; header=present',
          :disposition => "attachment; filename=event_statistics.csv")
      else
        @events = Event.date_filtered(@start_date,@end_date).includes([:tags, :presenters]).order("session_start ASC")
        returndata = "Event Statistics for #{@start_date} – #{@end_date}\n"
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


  def recommendations
    @recommendation_count = Recommendation.group("day").count
    @mailer_count = Recommendation.includes(:mailer_cache).where('mailer_caches.open_count > 0').group("day").count
    @recommended_event_counts = RecommendedEvent.includes([:event,{:recommendation => :learner}]).group("recommendations.day").count
    @recommended_event_viewed_counts = RecommendedEvent.includes([:event,{:recommendation => :learner}]).where(viewed: true).group("recommendations.day").count

    @connected_event_counts = {}
    RecommendedEvent.includes([:event,{:recommendation => :learner}]).each do |re|
      learner = re.recommendation.learner
      if(learner.events.include?(re.event))
        if(@connected_event_counts[re.recommendation.day])
          @connected_event_counts[re.recommendation.day] += 1
        else
          @connected_event_counts[re.recommendation.day] = 1
        end
      end
    end
  end

  def projected_recommendations
    event_options = {}
    event_options[:min_score] = params[:min_score] ? params[:min_score].to_i : Settings.minimum_recommendation_score
    event_options[:remove_connectors] = params[:remove_connectors] ? Preference::TRUE_PARAMETER_VALUES.include?(params[:remove_connectors]) : true
    @event_list = Event.projected_epoch.potential_learners(event_options)
  end

  def recommended_event
    @event = Event.find_by_id(params[:event_id])
    @event_options = {}
    @event_options[:min_score] = 1
    @event_options[:remove_connectors] = false
  end

  def recent_recommendations
    @recommended_event_list = RecommendedEvent.includes([:event,{:recommendation => :learner}]).order('recommended_events.created_at DESC').page(params[:page])
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
    headers << 'Canceled'
    headers << 'Expired'
    headers << 'Presenters'
    headers << 'Title'
    headers << 'Tags'
    headers << 'URL'
    headers << 'Recording'
    headers << 'Length'
    headers << 'Bookmarked'
    headers << 'Attended'
    headers << 'Watched'
    headers << 'Commentators'
    csv << headers
    events.each do |event|
      row = []
      row <<  event.session_start.strftime("%Y-%m-%d %H:%M:%S")
      row << ((event.is_canceled?) ? "canceled" : "")
      row << ((event.is_expired?) ? "expired" : "")
      row << event.presenters.collect{|learner| learner.name}.join('; ')
      row << event.title
      row << event.tags.collect{|tag| tag.name}.join('; ')
      row << event_url(event)
      row << ((event.has_recording?) ? event.recording : "n/a")
      row << event.session_length
      row << event.bookmarks_count
      row << event.attended_count
      row << event.watchers_count
      row << event.commentators_count
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
