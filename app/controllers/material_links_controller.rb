# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class MaterialLinksController < ApplicationController
  
  before_filter :authenticate_learner!
  
  def create
    return render :nothing => true if !current_learner.is_extension_account?
    @material_link = MaterialLink.new(params[:material_link])
    @errors = nil
    @event = Event.find(params[:material_link][:event_id])
    
    if !@material_link.save
      @errors = @material_link.errors.full_messages.to_sentence
    else
      @event_material_links = @material_link.event.material_links.order("created_at DESC")
      @material_link = MaterialLink.new
      respond_to do |format|
        format.js
      end
    end
  end
  
  def destroy
    
  end
  
end
