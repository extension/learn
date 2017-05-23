# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class RatingsController < ApplicationController
  before_filter :signin_required, only: [:create, :destroy]
  
  def create
    @rating = Rating.find_or_create_by_params(current_learner, params[:rating])
    # new rating was created, else it was found and learner cannot rate something twice
    if !@rating.persisted?
      if !@rating.save
        @errors = @rating.errors.full_messages.to_sentence
      end
    else
      return
    end
   
    respond_to do |format|
      format.js
    end
  end
  
  def destroy
    @rating = Rating.find_by_id(params[:id])
    
    if @rating.persisted?
      if !@rating.destroy
        @errors = @rating.errors.full_messages.to_sentence
      end
    else
      return
    end
    
    respond_to do |format|
      format.js
    end
  end
  
end
