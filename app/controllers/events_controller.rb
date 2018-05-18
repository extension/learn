# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class EventsController < ApplicationController
  before_filter :signin_required, only: [:edit, :update, :new, :create, :makeconnection, :backstage, :history, :destroy_registrants, :export_registrants, :delete_event]

  def index
    @list_title = 'All Sessions'
    params[:page].present? ? (@page_title = "#{@list_title} - Page #{params[:page]}") : (@page_title = @list_title)
    @events = Event.active.order('session_start DESC').page(params[:page])
  end

  def upcoming
    @list_title = 'Upcoming Sessions'
    params[:page].present? ? (@page_title = "#{@list_title} - Page #{params[:page]}") : (@page_title = @list_title)
    @events = Event.active.upcoming.order('session_start DESC').page(params[:page])
    render :action => 'index'
  end

  def recent
    @list_title = "Recent Sessions"
    params[:page].present? ? (@page_title = "#{@list_title} - Page #{params[:page]}") : (@page_title = @list_title)
    @events =  Event.active.recent.order('session_start DESC').page(params[:page])
    render :action => 'index'
  end

  def tags
    @showfeedlink = true
    @list_title = "Sessions Tagged With '#{params[:tags]}'"
    params[:page].present? ? (@page_title = "#{@list_title} - Page #{params[:page]}") : (@page_title = @list_title)


    if(params[:tags])
      if params[:type].present?
        if params[:type] == 'recent'
          @list_title = "Recent #{@list_title}"
          @events = Event.active.recent.tagged_with(params[:tags]).order('session_start DESC').page(params[:page])
        elsif params[:type] == 'upcoming'
          @list_title = "Upcoming #{@list_title}"
          @events = Event.active.upcoming.tagged_with(params[:tags]).order('session_start DESC').page(params[:page])
        else
          @events = Event.active.tagged_with(params[:tags]).order('session_start DESC').page(params[:page])
        end
      else
        @events = Event.active.tagged_with(params[:tags]).order('session_start DESC').page(params[:page])
      end
    else
      @events = Event.active.order('session_start DESC').page(params[:page])
    end

    render :action => 'index'
  end

  def diff_with_previous
    @event = Event.find(params[:id])
    @version = Version.find_by_id(params[:version_id])

    return record_not_found if !@version.present? || !@event.present?

    @previous_version = @version.previous

    @version_submitter = Learner.find_by_id(@version.whodunnit)

    if @version == @event.versions.first
      @previous_submitter = @event.creator
    else
      @previous_submitter = Learner.find_by_id(@previous_version.whodunnit)
    end

    if @version.changeset[:title].present?
      @title_diff = Diffy::Diff.new(@version.changeset[:title][0], @version.changeset[:title][1]).to_s(:html).html_safe
    end

    if @version.changeset[:description].present?
      @description_diff = Diffy::Diff.new(@version.changeset[:description][0], @version.changeset[:description][1]).to_s(:html).html_safe
    end

    if @version.changeset[:session_start].present?
      @session_start_diff = Diffy::Diff.new(@version.changeset[:session_start][0], @version.changeset[:session_start][1]).to_s(:html).html_safe
    end

    if @version.changeset[:session_length].present?
      @session_length_diff = Diffy::Diff.new(@version.changeset[:session_length][0], @version.changeset[:session_length][1]).to_s(:html).html_safe
    end

    if @version.changeset[:location].present?
      @location_diff = Diffy::Diff.new(@version.changeset[:location][0], @version.changeset[:location][1]).to_s(:html).html_safe
    end

    if @version.changeset[:evaluation_link].present?
      @evaluation_link_diff = Diffy::Diff.new(@version.changeset[:evaluation_link][0], @version.changeset[:evaluation_link][1]).to_s(:html).html_safe
    end

    if @version.changeset[:time_zone].present?
      @time_zone_diff = Diffy::Diff.new(@version.changeset[:time_zone][0], @version.changeset[:time_zone][1]).to_s(:html).html_safe
    end
  end

  def broadcast
    @list_title = "Broadcast Sessions"
    params[:page].present? ? (@page_title = "#{@list_title} - Page #{params[:page]}") : (@page_title = @list_title)

    @events = Event.active.broadcast.order('session_start DESC').page(params[:page])
    render :action => 'index'
  end

  def show
    @show_og_event_images = true
    @event = Event.find(params[:id])
    if(@event.requires_registration?)
      @has_registration_cookie = check_for_registration_cookie
    end
    @event_material_links = @event.material_links.order("created_at DESC")
    @comment = Comment.new
    @event_comments = @event.comments
    @similar_events = @event.similar_events
    if @event.tags.length != 0
      tracker do |t|
        t.google_tag_manager :push, { pageAttributes: @event.tags.map(&:name) }
      end
    end
    if @event.presenters.count > 0
      tracker do |t|
        t.google_tag_manager :push, { eventPresenters: @event.presenters.map(&:name) }
      end
    end


    if (@event.is_deleted)
      if (!current_learner || !current_learner.is_admin?)
        do_410
      end
    end

    if(current_learner)
      @last_viewed_at = current_learner.last_view_for_event(@event)
    end

  end

  def backstage
    @event = Event.find(params[:id])
    @attendees_count = @event.attendees.count
    @viewers_count = @event.viewers.count
    @followers_count = @event.followers.count
  end

  def history
    @event = Event.find(params[:id])
  end

  def recommended
    begin
      recommended_event = RecommendedEvent.find(params[:id])
    rescue
      return redirect_to(root_url, :error => 'Unable to find recommended event.', status: 301)
    end

    # log recommendation view, attach to learner on the recommendation, even if they aren't current_learner
    recommended_event.update_attribute(:viewed, true)
    return redirect_to(event_url(recommended_event.event), status: 301)
  end

  def new
    @event = Event.new

    3.times{@event.images.build}

    # seed defaults
    @event.session_start = Time.parse("14:00")
    if(current_learner)
      @event.time_zone = Time.zone
    end
  end

  def create
    @event = Event.new(params[:event])

    @event.last_modifier = @event.creator = current_learner

    if @event.save
      redirect_to(@event, :notice => 'Event was successfully created.')
    else
      render :action => 'new'
    end
  end

  def edit
    @event = Event.find(params[:id])

    # max of 3 total images allowed (including existing)
    new_image_count = 3 - @event.images.count
    if new_image_count > 0
      new_image_count.times do
        @event.images.build
      end
    end

  end

  def update
    @event = Event.find(params[:id])
    update_params = params[:event].merge({last_modifier: current_learner})

    if @event.update_attributes(update_params)
      redirect_to(@event, :notice => 'Event was successfully updated.')
    else
      render :action => 'edit'
    end
  end

  def restore
    @version = Version.find(params[:version])
    @restored_event = @version.reify
    # make sure @session_start_string Event instance variable is being set
    formatted_session_start = @restored_event.session_start_string
    if @restored_event.save
      redirect_to(@restored_event, :notice => 'Previous event version restored.')
    else
      flash[:error] = "Error restoring event."
      return redirect_to(@restored_event)
    end
  end

  def canceled
    @events = Event.where(is_canceled: true).order("session_start DESC").page(params[:page])
  end

  def deleted
    @events = Event.where(is_deleted: true).order("updated_at DESC").page(params[:page])
  end

  def makeconnection
    @event = Event.find(params[:id])
    if(connectiontype = params[:connectiontype])
      case connectiontype.to_i
      when EventConnection::FOLLOW
        if(params[:wantsconnection] and params[:wantsconnection] == '1')
          current_learner.connect_with_event(@event,EventConnection::FOLLOW)
        else
          current_learner.remove_connection_with_event(@event,EventConnection::FOLLOW)
        end
      when EventConnection::ATTEND
        if(params[:wantsconnection] and params[:wantsconnection] == '1')
          current_learner.connect_with_event(@event,EventConnection::ATTEND)
        else
          current_learner.remove_connection_with_event(@event,EventConnection::ATTEND)
        end
      when EventConnection::VIEW
        if(params[:wantsconnection] and params[:wantsconnection] == '1')
          current_learner.connect_with_event(@event,EventConnection::VIEW)
        else
          current_learner.remove_connection_with_event(@event,EventConnection::VIEW)
        end
      else
        # do nothing
      end
    end
  end

  def notificationexception
    @event = Event.find(params[:id])
    exception = NotificationException.where(learner_id: current_learner.id, event_id: @event.id)
    if !exception.empty?
      exception[0].destroy
    else
      NotificationException.create(learner: current_learner, event: @event)
    end
  end

  def export_registrants
    @event = Event.find(params[:id])
    if(@event.is_mfln_registration_event? and current_learner.is_mfln_registration_contact?)
      registrants = EventRegistration.where(event_id: @event.id)
      csv = EventRegistration.export(registrants)
      headers["Content-Disposition"] = "attachment; filename=\"event_#{@event.id}_registrants.csv\""
      render text: csv
    end
  end

  def destroy_registrants
    @event = Event.find(params[:id])
    if(@event.is_mfln_registration_event? and current_learner.is_mfln_registration_contact?)
      registrants = EventRegistration.where(event_id: @event.id)
      registrants.delete_all

      respond_to do |format|
        format.html { redirect_to event_path }
        format.xml  { head :ok }
      end
    end
  end

  def delete_event
    @event = Event.find(params[:id])
    if request.post?
      reason = params[:reason_is_deleted]
      if reason.blank?
        flash.now[:error] = 'Please document a reason for deleting this event.'
        return render nil
      end
      @event.update_attributes(is_deleted: true,
                               reason_is_deleted: reason
                               )
      flash[:success] = "Event deleted successfully"
      redirect_to event_url(@event)
    end
  end

  protected

  def check_for_registration_cookie
    if(evreglist = cookies.signed[:evreglist])
      return evreglist.include?(@event.id)
    elsif(cookies[:event_registration]) # old cookie - let's check and convert
      evreglist = cookies[:event_registration].split("&").map(&:to_i)
      cookies.delete(:event_registration)
      cookies.permanent.signed[:evreglist] = evreglist
      return evreglist.include?(@event.id)
    else
      return false
    end
  end

end
