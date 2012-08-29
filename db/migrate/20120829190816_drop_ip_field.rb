class DropIpField < ActiveRecord::Migration
  def change
    remove_column('activity_logs', 'ipaddr')
  end
end
