# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class MaterialLinksController < ApplicationController
  
  before_filter :authenticate_learner!
  
  def create
    @material_link = MaterialLink.new(params[:material_link])
    @errors = nil
    @event = Event.find(params[:material_link][:event_id])
    
    if !@material_link.save
      @errors = @material_link.errors.full_messages.to_sentence
    else
      @new_material_link_id = @material_link.id
      @event_material_links = @material_link.event.material_links.order("created_at DESC")
      @material_link = MaterialLink.new
      respond_to do |format|
        format.js
      end
    end
  end
  
  def destroy
    @material_link = MaterialLink.find_by_id(params[:id])
    
    if @material_link.persisted?
      if !@material_link.destroy
        @errors = @material_link.errors.full_messages.to_sentence
      end
    else
      return render :nothing => true
    end
    
    @event_material_links = @material_link.event.material_links.order("created_at DESC")
    
    respond_to do |format|
      format.js
    end
  end
  
  def edit
    @material_link = MaterialLink.find_by_id(params[:id])
    @event = @material_link.event
    @event_edit = true
    
    respond_to do |format|
      format.js
    end
  end
  
  def cancel_edit
    event = Event.find(params[:event_id])
    @event_material_links = event.material_links.order("created_at DESC")
    
    respond_to do |format|
      format.js
    end
  end
  
  def update
    @material_link = MaterialLink.find(params[:id])
    if !@material_link.update_attributes(params[:material_link])
      @errors = @material_link.errors.full_messages.to_sentence
    else
      @event_material_links = @material_link.event.material_links.order("created_at DESC")
    end
    
    respond_to do |format|
      format.js 
    end
  end
  
end
