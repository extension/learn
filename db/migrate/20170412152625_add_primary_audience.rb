class AddPrimaryAudience < ActiveRecord::Migration
  def change
    add_column(:events, :primary_audience, :integer, :null => false, :default => Event::AUDIENCE_BLANK)
  end
end
