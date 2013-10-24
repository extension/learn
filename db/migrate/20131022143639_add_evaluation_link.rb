class AddEvaluationLink < ActiveRecord::Migration
  def change
    add_column :events, :evaluation_link, :string, null: true
  end
end
