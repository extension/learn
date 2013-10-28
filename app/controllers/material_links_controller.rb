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
    @event = @material_link.event
    
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
      @material_link_id = @material_link.id
      if !@material_link.destroy
        @errors = @material_link.errors.full_messages.to_sentence
      end
    else
      return render :nothing => true
    end
    
    respond_to do |format|
      format.js
    end
  end
  
  def edit
    @material_link = MaterialLink.find_by_id(params[:id])
    @event = @material_link.event
    
    respond_to do |format|
      format.js
    end
  end
  
  def cancel_edit
    @material_link = MaterialLink.find(params[:material_link_id])
  
    respond_to do |format|
      format.js
    end
  end
  
  def update
    @material_link = MaterialLink.find(params[:id])
    if !@material_link.update_attributes(params[:material_link])
      @event = @material_link.event
      @errors = @material_link.errors.full_messages.to_sentence
    end
    
    respond_to do |format|
      format.js 
    end
  end
  
end
