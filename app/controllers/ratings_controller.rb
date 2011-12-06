# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class RatingsController < ApplicationController
  before_filter :authenticate_learner!, only: [:create]
  
  def create
    @rating = Rating.find_or_create_by_params(current_learner, params[:rating])
    
    if !@rating.save
      @errors = @rating.errors.full_messages.to_sentence
    end
   
    respond_to do |format|
      format.js
    end
  end
end
