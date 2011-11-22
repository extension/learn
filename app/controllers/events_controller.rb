# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class EventsController < ApplicationController
  before_filter :fake_learner
  before_filter :authenticate_learner!, only: [:addanswer, :edit, :update, :new, :create, :makeconnection]
  
  
  def show
    @event = Event.find(params[:id])
    # make sure @article has questions
    if(@event.questions.count == 0)
      @event.add_stock_questions
    end
    @comments = @event.comments
    # log view
    EventActivity.log_view(current_learner,@event) if(current_learner)
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
  end
  
  def edit
    @event = Event.find(params[:id])
  end
  
  def update
    @event = Event.find(params[:id])
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
        @update_attendee_list = true
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
    
end
