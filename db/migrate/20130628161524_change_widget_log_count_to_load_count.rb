class ChangeWidgetLogCountToLoadCount < ActiveRecord::Migration
  def change
    rename_column :widget_logs, :count, :load_count
  end
end
