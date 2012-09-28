# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class EventsController < ApplicationController
  before_filter :check_for_conference
  before_filter :authenticate_learner!, only: [:addanswer, :edit, :update, :new, :create, :makeconnection, :backstage, :history, :evaluation, :evaluationresults]
  
  def index
    @list_title = 'All Sessions'
    params[:page].present? ? (@page_title = "#{@list_title} - Page #{params[:page]}") : (@page_title = @list_title)
    if(@conference)
      @conference_display = true
      @events = @conference.events.active.order('session_start ASC').page(params[:page])
      @all_events_path = events_path
    else
      @events = Event.active.order('session_start DESC').page(params[:page])
    end
  end
  
  def upcoming
    @list_title = 'Upcoming Sessions'
    params[:page].present? ? (@page_title = "#{@list_title} - Page #{params[:page]}") : (@page_title = @list_title)
    @events = Event.nonconference.active.upcoming.order('session_start DESC').page(params[:page])
    render :action => 'index'
  end
  
  def recent
    @list_title = "Recent Sessions"
    params[:page].present? ? (@page_title = "#{@list_title} - Page #{params[:page]}") : (@page_title = @list_title)
    @events =  Event.nonconference.active.recent.order('session_start DESC').page(params[:page])
    render :action => 'index'
  end
  
  def tags
    # proof of concept - needs to be moved to something like Event.tagged_with(taglist)
    @list_title = "Sessions Tagged With '#{params[:tags]}'"
    params[:page].present? ? (@page_title = "#{@list_title} - Page #{params[:page]}") : (@page_title = @list_title)

    if(@conference)
      @conference_display = true
      if(params[:tags])
        @events = @conference.events.tagged_with(params[:tags]).order('session_start ASC').page(params[:page])
        @all_events_path = events_tag_path(:tags => params[:tags])
      else
        @events = @conference.events.order('session_start ASC').page(params[:page])
        @all_events_path = events_path
      end
    else
      if(params[:tags])
        @events = Event.active.tagged_with(params[:tags]).order('session_start DESC').page(params[:page])
      else
        @events = Event.active.order('session_start DESC').page(params[:page])
      end
    end
    render :action => 'index'
  end
    
  def show
    @event = Event.find(params[:id])
    return if check_for_event_redirect

    # there's a global time_zone setter - but we need to
    # do it again to make sure to force the time zone 
    # display to the session and not the system default
    if(@conference and !@conference.is_virtual?)
      Time.zone = @conference.time_zone
    elsif(current_learner and current_learner.has_time_zone?)
      Time.zone = current_learner.time_zone
    else
      Time.zone = @event.time_zone
    end

    if(!@event.is_conference_session?)
      # make sure the event has sense making questions
      if(@event.questions.count == 0 and !@event.is_conference_session?)
        @event.add_stock_questions
      end
    end

    @comments = @event.comments
    if(current_learner)
      @last_viewed_at = current_learner.last_view_for_event(@event)
    end

    # log view
    EventActivity.log_view(current_learner,@event) if(current_learner)
  end
  
  def backstage
    @event = Event.find(params[:id])
  end
  
  def history
    @event = Event.find(params[:id])
  end

  def evaluation
    @event = Event.find(params[:id])
    if(!@event.is_conference_session?)
      return redirect_to(event_path(@event))
    end
  end
  
  def evaluationresults
    @event = Event.find(params[:id])
    if(!@event.is_conference_session?)
      return redirect_to(event_path(@event))
    end
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
    if(@conference)
      @event.session_start = @conference.default_time
      @event.session_length = @conference.default_length
      @event.event_type = Event::CONFERENCE
      @event.time_zone = @conference.time_zone
      @event.conference = @conference
    else
      # seed defaults
      @event.session_start = Time.parse("14:00")
      if(current_learner)
        @event.time_zone = Time.zone
      end
    end
  end
  
  def create
    @event = Event.new(params[:event])
    if(@event.conference_id)
      @conference = Conference.find_by_id(@event.conference_id)
    end 
    @event.last_modifier = @event.creator = current_learner
    if @event.save
      redirect_to(@event, :notice => 'Event was successfully created.')
    else
      render :action => 'new'
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
  
  def search
    # take quotes out to see if it's a blank field and also strip out +, -, and "  as submitted by themselves are apparently special characters 
    # for solr and will make it crash, and if you ain't got no q param, no search goodies for you!
    if !params[:q] || params[:q].gsub(/["'+-]/, '').strip.blank?
      flash[:error] = "Empty/invalid search terms"
      return redirect_to root_url
    end

    # special "id of event check"
    if(params[:q].to_i > 0)
      id_number = params[:q].to_i
      if(event = Event.find_by_id(id_number))
        return redirect_to(event_path(event))
      end
    end

       
    @list_title = "Session Search Results for '#{params[:q]}'"
    params[:page].present? ? (@page_title = "#{@list_title} - Page #{params[:page]}") : (@page_title = @list_title)
    events = Event.search do
                with(:is_canceled, false)
                fulltext(params[:q])
                paginate :page => params[:page], :per_page => Event.default_per_page
              end
    @events = events.results
    render :action => 'index'
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


  def addevalanswer
    @event = Event.find(params[:id])

    # validate question 
    @evalquestion = EvaluationQuestion.find_by_id(params[:evalquestion])
    if(@evalquestion.nil?)
      return record_not_found
    end
    
    @evalquestion.create_or_update_answers(learner: current_learner, event: @event, params: params)
    
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

  protected

  def check_for_conference
    if(params[:conference_id])
      @conference = Conference.find_by_id_or_hashtag(params[:conference_id],false)

      if(@conference)
        # if not a virtual conference - force the timezone to be
        # that of the conference
        if(!@conference.is_virtual?)
          Time.zone = @conference.time_zone
        end
      end
    end
  end

  # must have @event
  def check_for_event_redirect
    if(@event.event_type == Event::CONFERENCE)
      if(!@conference)
        redirect_to(conference_event_url(:conference_id => @event.conference.hashtag, :id => @event.id))
        return true
      elsif(@event.conference != @conference)
        redirect_to(conference_event_url(:conference_id => @event.conference.hashtag, :id => @event.id))
        return true
      else
        return false
      end
    elsif(@event.event_type == Event::BROADCAST)
      # set the canonical to the event path
      @canonical_link = event_url(@event)
      return false
    else
      if(@conference)
        redirect_to(event_url(@event))
        return true
      else
        return false
      end
    end
  end



    
end
