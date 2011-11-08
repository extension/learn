# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class EventsController < ApplicationController
  before_filter :fake_learner
  before_filter :authenticate_learner!, only: [:addanswer]
  
  
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
  end
  
  def create
  end
  
  def edit
  end
  
  def update
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
  
  
end
