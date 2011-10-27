# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

require 'test_helper'

class StockQuestionTest < ActiveSupport::TestCase

  context "Creating a new stock question" do
    should validate_presence_of(:active)
    should validate_presence_of(:prompt)
    should validate_presence_of(:responsetype)
    should validate_presence_of(:responses)
    should validate_presence_of(:creator)
    should validate_numericality_of(:range_start) # TODO make sure integer only
    should validate_numericality_of(:range_end) # TODO make sure integer only
    should belong_to(:creator)
  end
  
  context "Given a set of stock questions" do 
    setup do
      @sq1 = Factory.create(:stock_question, responsetype: StockQuestion::BOOLEAN, responses: ['y','n'])
      @sq2 = Factory.create(:stock_question, responsetype: StockQuestion::SCALE, responses: ['least','most'])
      @sq3 = Factory.create(:stock_question, responsetype: StockQuestion::MULTIVOTE_BOOLEAN, responses: ['uno','dos','tres','quatro'])
    end
    
    
    should "asking for random items should return the number requested" do
      ask_for_count = 3
      question_list = StockQuestion.random_questions(3)
      assert_equal(ask_for_count,question_list.size)
    end
  end
  
end