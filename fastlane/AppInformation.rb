
require "cgi"

class AppInformation
  @app_name = ""
  @bundle_id = ""
  @prod_ua_app_key = ""
  @prod_ua_app_secret_key = ""
  @cert_ua_app_key = ""
  @cert_ua_app_secret_key = ""
  @acronym = ""
  @app_short_code = ""
  @full_description = ""
  @app_id = ""
  @bundle_identifier = ""


  def bundle_identifier
    return @bundle_identifier
  end

  def app_name
    return @app_name
  end

  def app_acronym
    return @app_acronym
  end

  def app_id
  	return @app_id
  end

  def app_short_code
  	return @app_short_code
  end

  def full_description
  	return @full_description
  end


  def bundle_id
    return @bundle_id
  end

  def bundle_id
    return @bundle_id
  end

  def initialize(info)
    @row = info
    @bundle_id = @row['bundle_id']
    @app_name = CGI.unescapeHTML("#{@row['app_name']}").gsub('\&','&')
    @prod_ua_app_key = @row['prod_ua_app_key']
    @prod_ua_app_secret_key = @row['prod_ua_app_secret_key']
    @cert_ua_app_key = @row['cert_ua_app_key']
    @cert_ua_app_secret_key = @row['cert_ua_app_secret_key']
    @app_acronym = @row['app_acronym']
    @app_short_code = @row['App_Short_Code']
    @full_description = @row['full_description']
    @app_id = @row['app_id']
    @bundle_identifier = @row['bundle_identifier']
  end
end
