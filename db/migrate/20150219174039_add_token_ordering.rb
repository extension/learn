class AddTokenOrdering < ActiveRecord::Migration
  def change
    add_column :events, :provided_presenter_order, :text
  end

end
