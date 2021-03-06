# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class LearnersController < ApplicationController
  before_filter :signin_optional, only: [:portfolio]
  before_filter :signin_required, except: [:portfolio, :register_learner]

  def portfolio
    @learner = Learner.find(:first, :conditions => {:id => params[:id]}, :include => [:portfolio_setting, :preferences])
    return record_not_found if !@learner

    @attended_events = @learner.attended_events.order("event_connections.created_at DESC").limit(5)
    @viewed_events = @learner.viewed_events.order("event_connections.created_at DESC").limit(5)
    @presented_events = @learner.presented_events.active.order("session_start DESC").limit(5)
    @followed_events = @learner.followed_events.order("event_connections.created_at DESC").limit(5)
  end

  def learning_history
    @learner = current_learner
    prepare_history('Activity')
    @list_title = "Your Activity Log"
    # don't think there's a better AR way of doing this, it's pretty fast as is
    @activities = @learner.activity_logs.select("activity_logs.created_at AS created_at, ea.*, e.title AS title, e.id AS event_id").joins("JOIN event_activities AS ea on ea.id = activity_logs.loggable_id JOIN events as e on e.id = ea.event_id").where("e.is_canceled = 0 AND activity_logs.loggable_type = 'EventActivity' AND ea.activity IN (#{EventActivity::HISTORY_ITEMS.join(',')})").order("activity_logs.created_at DESC").page(params[:page])
  end

  def presented_history
    @learner = Learner.includes(:preferences).where(id: params[:id]).first
    return record_not_found if !@learner
    prepare_history('Presented')
    @events = @learner.presented_events.active.order('session_start DESC').page(params[:page])
    render :action => 'learning_history'
  end

  def created_history
    @learner = Learner.includes(:preferences).where(id: params[:id]).first
    return record_not_found if !@learner
    prepare_history('Created')
    @events = @learner.created_events.active.order('session_start DESC').page(params[:page])
    render :action => 'learning_history'
  end

  def attended_history
    @learner = Learner.includes(:preferences).where(id: params[:id]).first
    return record_not_found if !@learner
    prepare_history('Attended')
    @events = @learner.events.active.attended.order('session_start DESC').page(params[:page])
    render :action => 'learning_history'
  end

  def viewed_history
    @learner = Learner.includes(:preferences).where(id: params[:id]).first
    return record_not_found if !@learner
    prepare_history('Viewed')
    @events = @learner.events.active.viewed.order('session_start DESC').page(params[:page])
    render :action => 'learning_history'
  end

  def followed_history
    @learner = Learner.includes(:preferences).where(id: params[:id]).first
    return record_not_found if !@learner
    prepare_history('Followed')
    @list_title = "Followed by #{@learner.name}"
    @events = @learner.followed_events.order('session_start DESC').page(params[:page])
    render :action => 'learning_history'
  end

  def token_search
    @learners = Learner.where("name like ?", "%#{params[:q]}%")
    token_hash = @learners.collect{|learner| {id: learner.id, name: learner.name}}
    render(json: token_hash)
  end

  def register_learner
    @event = Event.find(params[:event_id])
    @registration = EventRegistration.new(first_name: params[:first_name],
                                          last_name: params[:last_name],
                                          email: params[:email],
                                          event_id: params[:event_id])

    #This is a little wonky but allows us to keep the event/email validation, but not display an error

    # we are explicitly filtering out the duplicate event+email error but keeping the rest of the validations
    # as a user error.  It probably should be highlighted on the form itself, but one thing at a time.
    if !@registration.valid? and @registration.errors.full_messages.to_sentence != "Event has already been taken"
      errors = @registration.errors.full_messages
      errors.delete("Event has already been taken")
      flash[:notice] = errors.to_sentence
      redirect_to(event_path(@event))
    else
      @registration.save
      if(evreglist = cookies.signed[:evreglist])
        # push the token for this event into the cookie
        evreglist << @event.id
        evreglist.uniq!
        cookies.permanent.signed[:evreglist] = evreglist
      else
        evreglist = [@event.id]
        cookies.permanent.signed[:evreglist] = evreglist
      end
      redirect_to(event_path(@event), :notice => "Thank you. A confirmation email has been sent to #{@registration.email}.")
    end
  end

  private

  def prepare_history(history_type)
    @type = history_type
    @list_title = "#{@type} by #{@learner.name}"
    params[:page].present? ? (@page_title = "#{@list_title} - Page #{params[:page]}") : (@page_title = @list_title)
  end

  def authenticate_portfolio_if_not_public
    if params[:id] && learner = Learner.find_by_id(params[:id])
      if learner.public_portfolio?
        return
      end
    end

    signin_required
  end

end
