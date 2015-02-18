class AddPositionToPresenterConnections < ActiveRecord::Migration
  def change
    add_column :presenter_connections, :position, :integer
  end
end
