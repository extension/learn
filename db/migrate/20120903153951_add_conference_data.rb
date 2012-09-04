class AddConferenceData < ActiveRecord::Migration
  def up
        # Create nexc2012 to have something to work against
    # change learnbots name to something friendlier because 'Learn System User' looks stupid
    Learner.learnbot.update_attribute(:name, 'Learn')

    Conference.reset_column_information
    nexc2012 = Conference.create(:name => 'eXtension 2012 National Conference', 
                      :hashtag => 'nexc2012', 
                      :tagline => 'SPUR ON the Evolution of Extension',
                      :website => 'http://nexc2012.extension.org',
                      :description => 'To be added.',
                      :start_date => '2012-10-01',
                      :end_date => '2012-10-04',
                      :creator => Learner.learnbot,
                      :last_modifier => Learner.learnbot,
                      :time_zone => 'Central Time (US & Canada)',
                      :is_virtual => false)


    # evaluation questions
    EvaluationQuestion.reset_column_information
    EvaluationQuestion.create(conference: nexc2012, 
                              prompt: "How would you rate the usefulness of this presentation to your daily work?",
                              responsetype: EvaluationQuestion::MULTIPLE_CHOICE,
                              questionorder: 1,
                              responses: ['Very useful','Somewhat useful','Of very little use','Not at all useful'],
                              creator: Learner.learnbot)

    EvaluationQuestion.create(conference: nexc2012, 
                              prompt: "Will you apply information learned in this presentation to your daily work?",
                              responsetype: EvaluationQuestion::MULTIPLE_CHOICE,
                              questionorder: 2,
                              responses: ['Apply immediately','Apply in the future','Not sure','Will not apply'],
                              creator: Learner.learnbot)

    EvaluationQuestion.create(conference: nexc2012, 
                              prompt: "What is your overall rating of this presentation?",
                              responsetype: EvaluationQuestion::MULTIPLE_CHOICE,
                              questionorder: 3,
                              responses: ['Excellent','Good','Acceptable','Fair','Poor'],
                              creator: Learner.learnbot)

    EvaluationQuestion.create(conference: nexc2012, 
                              prompt: "Would you recommend this presentation to your peers?",
                              responsetype: EvaluationQuestion::MULTIPLE_CHOICE,
                              questionorder: 4,
                              responses: ['Definitely I would recommend','Probably I would recommend','Uncertain if I would recommend','Probably I would not recommend','Definitely I would not recommend'],
                              creator: Learner.learnbot)

    EvaluationQuestion.create(conference: nexc2012, 
                              prompt: "Would you like more information about this topic?",
                              secondary_prompt: 'Please comment on what additional information would be helpful:',
                              responsetype: EvaluationQuestion::COMPOUND_MULTIPLE_OPEN,
                              questionorder: 5,
                              responses: {responsestrings: ['Yes','Maybe','No'], triggers: ['Yes','Maybe']},
                              creator: Learner.learnbot)


  end

  def down
    # nothing to do here
  end
  
end
