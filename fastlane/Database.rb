require "json"
require "open-uri"
require "Mysql2"
load "AppInformation.rb"
class Database
  def initialize
    @consumerID = ENV["CONSUMER_ID"]
    @prod_query = "SELECT *
    FROM
    ((`Apps`
    JOIN `build_script` ON ((`Apps`.`App_ID` = `build_script`.`app_id`)))
    JOIN `build_ios` ON ((`build_script`.`id` = `build_ios`.`build_id`)))"
    @prod_client = Mysql2::Client.new(
    :host     => ENV["JBSM_IOS_PROD_DB_URL"],
    :username => ENV["JBSM_IOS_PROD_DB_USERNAME"],
    :password => ENV["JBSM_IOS_PROD_DB_PASSWORD"],
    :database => ENV["JBSM_IOS_PROD_DB_TABLE"]
    )
  end

  def get_app_short_codes
    buffer = open("https://build.elsevier-jbs.com/build/app/all",
    "consumerid" => @consumerID).read
    return JSON.parse(buffer)["app_short_code"]
  end

  def get_app_metadata_by_app_short_code(app_short_code)
      buffer = open("https://build.elsevier-jbs.com/build/#{app_short_code}/ios",
      "consumerid" => @consumerID).read
      return JSON.parse(buffer)
  end

  def get_app_description_by_short_code(app_short_code)
    appInfo = Hash.new("")
    prodResults = @prod_client.query(@prod_query +  " WHERE App_Short_Code = \"#{app_short_code}\"")
    prodResults.map do |row|
      item = AppInformation.new(row)
      return item
    end
  end
end
