class AddLinkCheckingFields < ActiveRecord::Migration
  def change
    add_column(:material_links, "fingerprint", :string)
    add_column(:material_links, "host", :string)
    add_column(:material_links, "path", :text)
    add_column(:material_links, "status", :integer)
    add_column(:material_links, "error_count", :integer, :default => 0)
    add_column(:material_links, "last_check_at", :datetime)
    add_column(:material_links, "last_check_status", :integer)
    add_column(:material_links, "last_check_code", :string)
    add_column(:material_links, "last_check_response", :boolean)
    add_column(:material_links, "last_check_information", :text)
  end

  def down
  end
end
