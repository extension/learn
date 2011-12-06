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
