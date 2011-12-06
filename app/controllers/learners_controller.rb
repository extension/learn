# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class LearnersController < ApplicationController
  
  def index
  end
  
  def show
  end
  
  def portfolio
    @learner = Learner.find(params[:id])
  end
  
  def learning_history  
  end
  
end
