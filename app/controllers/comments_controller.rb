# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class CommentsController < ApplicationController
  before_filter :signin_required, only: [:create, :update]
  
  def create 
    @comment = Comment.new(params[:comment])
    @errors = nil
    @comment.learner = current_learner
    @event = @comment.event
    
    if !@comment.save
      @errors = @comment.errors.full_messages.to_sentence
    else
      @event = @comment.event
      @comment = Comment.new
      # if parent_comment_id exists, we're only going to pull the parent comment and it's subtree, 
      # because this is getting called from the parent comment's view page
      if params[:parent_comment_id].blank?
        @event_comments = @event.comments
        @parent_comment = nil
      else
        @event_comments = Comment.find(params[:parent_comment_id]).subtree
        @parent_comment = @comment
      end
    end
    
    respond_to do |format|
      format.js
    end
  end
  
  def update 
    @comment = Comment.find(params[:id])
    if @comment.learner_id == current_learner.id
      if !@comment.update_attributes(params[:comment])
        @errors = @comment.errors.full_messages.to_sentence
      else
        @event = @comment.event
        # if parent_comment_id exists, we're only going to pull the parent comment and it's subtree, 
        # because this is getting called from the parent comment's view page as the parent comment is 
        # getting updated and we're only showing the parent and it's children on it's view page
        if params[:parent_comment_id].blank?
          @comments = @event.comments
          @parent_comment = nil
        else
          @parent_comment = Comment.find(params[:parent_comment_id])
          @comments = @parent_comment.subtree
        end
      end
    else
      @errors = "You cannot edit this comment as you are not the author."
    end
    respond_to do |format|
      format.js
    end
  end
  
  def destroy
    @comment = Comment.find(params[:id])
    
    if @comment.learner_id == current_learner.id
      if @comment.persisted?
        @comment_id = @comment.id
        if !@comment.destroy
          @errors = @comment.errors.full_messages.to_sentence
        end
      else
        return render :nothing => true
      end
    
      respond_to do |format|
        format.js
      end
    end
  end
  
  def reply
    @parent_comment = Comment.find_by_id(params[:comment_id])
    @event = @parent_comment.event
    @comment = Comment.new
    
    respond_to do |format|
      format.js
    end
  end
  
  def show
    @comment = Comment.find_by_id(params[:id])
    if !@comment || @comment.created_by_blocked_learner?  
      return record_not_found
    end
  end
  
  def edit
    @comment = Comment.find_by_id(params[:id])
    @event = @comment.event
    
    respond_to do |format|
      format.js
    end
  end
  
  def cancel_edit
    @comment = Comment.find(params[:comment_id])
  
    respond_to do |format|
      format.js
    end
  end
  
  def cancel_reply
    @comment = Comment.find(params[:comment_id])
  
    respond_to do |format|
      format.js
    end
  end
  
end
