require 'csv'
class RegistrantsExport
	HEADERS = ['first_name', 'last_name', 'email'].freeze
	attr_reader :registrants

	def initialize(registrants)
		@registrants = registrants
	end

	def to_csv
		CSV.generate do |csv|
      headers = []
      headers << 'First Name'
      headers << 'Last Name'
      headers << 'Email'
      headers << 'Date Registered'
      csv << headers
      registrants.each do |registrant|
        row = []
        row << registrant.first_name
        row << registrant.last_name
        row << registrant.email
        row << registrant.created_at
        csv << row
      end
		end
	end
end