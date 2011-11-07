# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

require 'test_helper'

class QuestionTest < ActiveSupport::TestCase

  context "Creating a new question" do
    should validate_presence_of(:prompt)
    should validate_presence_of(:responsetype)
    should validate_presence_of(:responses)
    should validate_presence_of(:event)
    should validate_presence_of(:learner)
    should validate_numericality_of(:range_start) # TODO make sure integer only
    should validate_numericality_of(:range_end) # TODO make sure integer only
    should validate_numericality_of(:priority) # TODO make sure integer only
    should have_many(:answers)
    should belong_to(:event)
    should belong_to(:learner)
  end
  
  
  context "Creating answers" do 
    setup do
      @learner = Factory.create(:learner)
      @event = Factory.create(:event, learner: @learner, last_modifier: @learner)
    end
    
    context "for a boolean question" do
      setup do
        @q_boolean = Factory.create(:question, responsetype: Question::BOOLEAN, responses: ['y','n'], learner: @learner, event: @event)
      end
    
      should "create one answer if doesn't exist" do
        assert_equal(0,@q_boolean.answers.count)
        @q_boolean.create_or_update_answers(learner: @learner, update_value: 0)
        assert_equal(1,@q_boolean.answers.count)
      end
      
      should "update answer if one exists" do
        Answer.create(learner: @learner, question: @q_boolean, value: 0)
        assert_equal(1,@q_boolean.answers.count)
        @q_boolean.create_or_update_answers(learner: @learner, update_value: 1)
        assert_equal(1,@q_boolean.answers.first.value)
      end
      
      should "return the expected answer data given a set of answers" do
        expected_result = []
        @q_boolean.responses.each do |response| 
          Answer.create(learner: @learner, question: @q_boolean, value: 1, response: response)
          expected_result << [response,1]
        end
        assert_equal(expected_result,@q_boolean.answer_data)
      end
    end
    
    context "for a scale question" do
      setup do
        @q_scale = Factory.create(:question, responsetype: Question::SCALE, responses: ['least','most'], range_start: 1, range_end: 5, learner: @learner, event: @event)
      end
    
      should "create one answer if doesn't exist" do
        assert_equal(0,@q_scale.answers.count)
        @q_scale.create_or_update_answers(learner: @learner, update_value: 42)
        assert_equal(1,@q_scale.answers.count)
      end
      
      should "update answer if one exists" do
        Answer.create(learner: @learner, question: @q_scale, value: 42)
        assert_equal(1,@q_scale.answers.count)
        @q_scale.create_or_update_answers(learner: @learner, update_value: 24)
        assert_equal(24,@q_scale.answers.first.value)
      end
      
      
      should "return the expected answer data given a set of answers" do
        expected_result = []
        @q_scale.range_start.upto(@q_scale.range_end).each do |value| 
          Answer.create(learner: @learner, question: @q_scale, value: value)
          expected_result << [value,1]
        end
        assert_equal(expected_result,@q_scale.answer_data)
      end
    end
    
    context "for a multivote boolean question" do
      setup do
        @q_multivote_boolean = Factory.create(:question, responsetype: Question::MULTIVOTE_BOOLEAN, responses: ['uno','dos','tres','quatro'], learner: @learner, event: @event)
      end

      should "create answers for the provided values if they don't exist" do
        expected_answers = 3
        answer_values = ['uno','dos','quatro','nonsense']
        @q_multivote_boolean.create_or_update_answers(learner: @learner, update_value: answer_values)
        assert_equal(expected_answers,@q_multivote_boolean.answers.count)
        responses = @q_multivote_boolean.answers.map(&:response)
        assert(answer_values - responses == ['nonsense'])
      end
      
      should "update answers if exists" do
        initial_responses = ['uno','dos']
        initial_responses.each do |response|  
          Answer.create(learner: @learner, question: @q_multivote_boolean, value: 1, response: response)
        end
        assert_equal(2,@q_multivote_boolean.answers.count)
        initial_saved_responses = @q_multivote_boolean.answers.map(&:response)
        assert(initial_responses - initial_saved_responses == [])
        
        update_responses = ['quatro']
        @q_multivote_boolean.create_or_update_answers(learner: @learner, update_value: update_responses)
        assert_equal(1,@q_multivote_boolean.answers.count)
        update_saved_responses = @q_multivote_boolean.answers.map(&:response)
        assert(update_responses - update_saved_responses == [])
      end
    
      should "delete all answers if nil update_value provided" do
        initial_responses = ['uno','dos','tres','quatro']
        initial_responses.each do |response|  
          Answer.create(learner: @learner, question: @q_multivote_boolean, value: 1, response: response)
        end
        assert_equal(4,@q_multivote_boolean.answers.count)
        @q_multivote_boolean.create_or_update_answers(learner: @learner, update_value: nil)
        assert_equal(0,@q_multivote_boolean.answers.count)
      end
      
      should "return the expected answer data given a set of answers" do
        expected_result = []
        @q_multivote_boolean.responses.each do |response| 
          Answer.create(learner: @learner, question: @q_multivote_boolean, value: 1, response: response)
          expected_result << [response,1]
        end
        assert_equal(expected_result,@q_multivote_boolean.answer_data)
      end
      
    end
    
  end
end
