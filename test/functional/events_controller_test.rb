# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

require 'test_helper'

class EventsControllerTest < ActionController::TestCase
  
  context "As an unauthenticated account" do 
    setup do
      @event = Factory.build(:event)
      @event.id = 42
      
      Event.stubs(:find).returns(@event)
      Event.stubs(:find).with(:all).returns([@event])
    end
        
    context "getting show" do
      setup do 
        get :show, id: @event.id
      end
    
      should assign_to(:event){@event} 
      should respond_with :success
      should render_template :show
      should_not set_the_flash
    end
    
    context "getting recommended_event with a recommended_event_id" do
      setup do
        @recommended_event = Factory.create(:recommended_event)
        get :recommended, id: @recommended_event.id
      end
      
      should redirect_to("events path"){event_url(@recommended_event.event)}
      should "log event activity" 
    end
    
  end # unauthenticated
                
end
