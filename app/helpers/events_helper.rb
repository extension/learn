# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

module EventsHelper
  
  def is_boolean_answer_checked?(question,answer_value)
    if(!current_learner)
      false
    elsif(!(value = question.answer_value_for_learner_and_response(learner: current_learner)))
      false
    else
      value == answer_value
    end
  end
  
  
  def is_multivote_answer_checked?(question,response)
    if(!current_learner)
      false
    elsif(!(value = question.answer_value_for_learner_and_response(learner: current_learner, response: response)))
      false
    else
      # should always be true
      value == 1
    end
  end
  
  def scale_value(question)
    if(!current_learner)
      nil
    else
      question.answer_value_for_learner_and_response(learner: current_learner)
    end
  end
  
  def multivote_scale_value(question,response)
    if(!current_learner)
      nil
    else
      question.answer_value_for_learner_and_response(learner: current_learner, response: response)
    end
  end
  
  
  def jqplot_bargraph_data(question)
    question.answer_data.map{|(label,value)| value}.to_json.html_safe
  end
  
  def jqplot_bargraph_xaxis_labels(question)
     (question.range_start..question.range_end).to_a.map{|i|i.to_s}.to_json.html_safe
  end
  
  def jqplot_piegraph_data(question)
    question.answer_data.to_json.html_safe
  end
  
end
