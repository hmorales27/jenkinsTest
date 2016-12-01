require_relative '../Database.rb'

#To run this, simply run "ruby DatabaseTest.rb" from directory fastlane

puts ENV["CONSUMER_ID"]
db = Database.new
app_short_codes = db.get_app_short_codes
app_build_metadata = db.get_app_metadata_by_app_short_code(app_short_codes[0])
puts app_short_codes[0]
puts app_build_metadata
