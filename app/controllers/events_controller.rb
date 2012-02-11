# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class EventsController < ApplicationController
  before_filter :authenticate_learner!, only: [:addanswer, :edit, :update, :new, :create, :makeconnection, :details, :history]
  
  def index
    @list_title = 'All Sessions'
    params[:page].present? ? (@page_title = "#{@list_title} - Page #{params[:page]}") : (@page_title = @list_title)
    @events = Event.active.paginate(:page => params[:page]).order('session_start DESC')
  end
  
  def upcoming
    @list_title = 'Upcoming Sessions'
    params[:page].present? ? (@page_title = "#{@list_title} - Page #{params[:page]}") : (@page_title = @list_title)
    @events = Event.active.upcoming.paginate(:page => params[:page]).order('session_start DESC')
    render :action => 'index'
  end
  
  def recent
    @list_title = "Recent Sessions"
    params[:page].present? ? (@page_title = "#{@list_title} - Page #{params[:page]}") : (@page_title = @list_title)
    @events =  Event.active.recent.paginate(:page => params[:page]).order('session_start DESC')
    render :action => 'index'
  end
  
  def tags
    # proof of concept - needs to be moved to something like Event.tagged_with(taglist)
    @list_title = "Sessions Tagged With '#{params[:tags]}'"
    params[:page].present? ? (@page_title = "#{@list_title} - Page #{params[:page]}") : (@page_title = @list_title)
    if(params[:tags])
      @events = Event.active.tagged_with(params[:tags]).paginate(:page => params[:page]).order('session_start DESC')
    else
      @events = Event.active.paginate(:page => params[:page]).order('session_start DESC')
    end
    render :action => 'index'
  end
    
  def show
    @event = Event.find_by_id(params[:id])
    # dup of global before filter logic in order
    # to force display of event time in the time zone of the session
    if(current_learner and current_learner.has_time_zone?)
      Time.zone = current_learner.time_zone
    else
      Time.zone = @event.time_zone
    end

    # make sure @article has questions
    if(@event.questions.count == 0)
      @event.add_stock_questions
    end
    @comments = @event.comments
    # log view
    EventActivity.log_view(current_learner,@event) if(current_learner)
  end
  
  def details
    @event = Event.find_by_id(params[:id])
  end
  
  def history
    @event = Event.find_by_id(params[:id])
  end
  
  def recommended
    begin
      recommended_event = RecommendedEvent.find(params[:id])   
    rescue
      return redirect_to(root_url, :error => 'Unable to find recommended event.', status: 301)
    end
    
    # log recommendation view, attach to learner on the recommendation, even if they aren't current_learner
    recommended_event.update_attribute(:viewed, true)
    EventActivity.log_view(recommended_event.recommendation.learner,recommended_event.event,'recommendation')
    return redirect_to(event_url(recommended_event.event), status: 301)
  end
  
  def new
    @event = Event.new
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
      render :action => 'edit'
    end
  end
  
  def edit
    @event = Event.find(params[:id])
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
    if @restored_event.save
      redirect_to(@restored_event, :notice => 'Previous event version restored.')
    end
  end
  
  def deleted
    @events = Event.where(deleted: true).paginate(:page => params[:page]).order("session_start DESC")
  end
  
  # the record does not get destroyed,
  # the deleted flag gets set and the 
  # event is excluded from queries
  def set_deleted_flag
    @event = Event.find(params[:id])
    @event.update_attribute(:deleted, true)
    EventActivity.log_delete(current_learner,@event)
    flash[:notice] = "Event successfully deleted."
    redirect_to event_url(@event.id)
  end
  
  def undelete
    @event = Event.find(params[:id])
    @event.update_attribute(:deleted, false)
    EventActivity.log_undelete(current_learner,@event)
    flash[:notice] = "Event successfully restored."
    redirect_to event_url(@event.id)
  end
  
  def search
    # take quotes out to see if it's a blank field and also strip out +, -, and "  as submitted by themselves are apparently special characters 
    # for solr and will make it crash
    if params[:q].gsub(/["'+-]/, '').strip.blank?
      flash[:error] = "Empty/invalid search terms"
      return redirect_to root_url
    end
    
    @list_title = "Session Search Results for '#{params[:q]}'"
    params[:page].present? ? (@page_title = "#{@list_title} - Page #{params[:page]}") : (@page_title = @list_title)
    events = Event.search do
                with(:deleted, false)
                fulltext(params[:q])
                paginate :page => params[:page], :per_page => Event.per_page
              end
    @events = events.results
    render :action => 'index'
  end
  
  def learner_token_search
    @learners = Learner.where("name like ?", "%#{params[:q]}%")
    token_hash = @learners.collect{|learner| {id: learner.id, name: learner.name}}
    render(json: token_hash)
  end

  
  def addanswer
    @event = Event.find(params[:id])
    
    # validate question 
    @question = Question.find_by_id(params[:question])
    if(@question.nil?)
      return record_not_found
    end
    
    if(@question.event != @event)
      return bad_request('Invalid question specified')
    end
    
    # simple type checking for values
    if(@question.responsetype != Question::MULTIVOTE_BOOLEAN and !params[:values])
      return bad_request('Empty values specified')
    end
    
    if((@question.responsetype == Question::MULTIVOTE_BOOLEAN) and params[:values] and !params[:values].is_a?(Array))
      return bad_request('Must provide array values for this question type')
    end
        
    # create or update answers
    @question.create_or_update_answers(learner: current_learner, update_value: params[:values])
    
    respond_to do |format|
      format.js
    end
  end
  
  def makeconnection
    @event = Event.find(params[:id])
    if(connectiontype = params[:connectiontype])
      case connectiontype.to_i
      when EventConnection::BOOKMARK
        if(params[:wantsconnection] and params[:wantsconnection] == '1')
          current_learner.connect_with_event(@event,EventConnection::BOOKMARK)
        else
          current_learner.remove_connection_with_event(@event,EventConnection::BOOKMARK)
        end
      when EventConnection::ATTEND
        if(params[:wantsconnection] and params[:wantsconnection] == '1')
          current_learner.connect_with_event(@event,EventConnection::ATTEND)
        else
          current_learner.remove_connection_with_event(@event,EventConnection::ATTEND)
        end
      when EventConnection::WATCH
        if(params[:wantsconnection] and params[:wantsconnection] == '1')
          current_learner.connect_with_event(@event,EventConnection::WATCH)
        else
          current_learner.remove_connection_with_event(@event,EventConnection::WATCH)
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
    
end
