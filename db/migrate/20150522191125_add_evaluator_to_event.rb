class AddEvaluatorToEvent < ActiveRecord::Migration
  def change
  	add_column :events, :evaluator_id, :integer
  end
end
