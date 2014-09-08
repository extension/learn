class ChangeReferrerField < ActiveRecord::Migration
  def up
    change_column(:widget_logs, :referrer_url, :text)
  end
end
