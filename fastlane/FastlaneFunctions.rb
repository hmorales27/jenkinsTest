require_relative 'Database.rb'
require 'fileutils'
require_relative 's9splashgen.rb'

class FastlaneFunctions

  def initialize
    @db = Database.new
    @appShortCodeList
    @splashScreenResizer = SplashScreenResizer.new
    @root_dir = FileUtils.pwd
    @root_dir.slice! "/fastlane"
  end


  def get_app_short_codes
    if @appShortCodeList == nil
      @appShortCodeList = @db.get_app_short_codes()
    end
    return @appShortCodeList
  end

  def get_app_metadata_by_app_short_code(app_short_code)
    return @db.get_app_metadata_by_app_short_code(app_short_code)
  end

  def update_urban_airship(ua_cert_app_key, ua_cert_app_secret, ua_prod_app_key, ua_prod_app_secret)

    `/usr/libexec/PlistBuddy -c "Set productionAppKey "#{ua_prod_app_key} #{@root_dir}/AirshipConfig.plist 2> /dev/null`
    `/usr/libexec/PlistBuddy -c "Set productionAppSecret "#{ua_prod_app_secret} #{@root_dir}/AirshipConfig.plist 2> /dev/null`
    `/usr/libexec/PlistBuddy -c "Set developmentAppKey "#{ua_cert_app_key} #{@root_dir}/AirshipConfig.plist 2> /dev/null`
    `/usr/libexec/PlistBuddy -c "Set developmentAppSecret "#{ua_cert_app_secret} #{@root_dir}/AirshipConfig.plist 2> /dev/null`

  end

  def update_images(pathGraphicsResource)

    FileUtils.cp Dir.glob(pathGraphicsResource + "/" + 'default_journal_ipad_L*.png'), "#{@root_dir}/Assets/images.xcassets/DefaultBrandLogo-Landscape.imageset", :verbose=>true
    FileUtils.cp Dir.glob(pathGraphicsResource + "/" + 'default_journal_ipad_P*.png'), "#{@root_dir}/Assets/images.xcassets/DefaultBrandLogo-Portrait.imageset", :verbose=>true
    FileUtils.cp Dir.glob(pathGraphicsResource + "/" + 'default_journal_ipad_P*.png'), "#{@root_dir}/Assets/images.xcassets/DefaultBrandLogo-Phone.imageset", :verbose=>true

    FileUtils.cp Dir.glob(pathGraphicsResource + "/" + 'default_journal_ipad_L*.png'), "#{@root_dir}/Assets/images.xcassets/DefaultBrandLogo-Landscape.imageset", :verbose=>true
    FileUtils.cp Dir.glob(pathGraphicsResource + "/" + 'default_journal_ipad_P*.png'), "#{@root_dir}/Assets/images.xcassets/DefaultBrandLogo-Portrait.imageset", :verbose=>true
    FileUtils.cp Dir.glob(pathGraphicsResource + "/" + 'default_journal_ipad_P*.png'), "#{@root_dir}/Assets/images.xcassets/DefaultBrandLogo-Phone.imageset", :verbose=>true

    FileUtils.cp Dir.glob(pathGraphicsResource + "/" + 'default_cover_ipad*.png'),   "#{@root_dir}/Assets/images.xcassets/DefaultCoverImage-iPad.imageset", :verbose=>true
    FileUtils.cp Dir.glob(pathGraphicsResource + "/" + 'default_cover_iphone*.png'), "#{@root_dir}/Assets/images.xcassets/DefaultcoverImage-iPhone.imageset", :verbose=>true

    FileUtils.cp Dir.glob(pathGraphicsResource + "/" + 'society_branding_graphic_ipad*.png'), "#{@root_dir}/Assets/images.xcassets/DefaultSocietyLogo-Landscape.imageset", :verbose=>true
    FileUtils.cp Dir.glob(pathGraphicsResource + "/" + 'society_branding_graphic_portrait_ipad*.png'), "#{@root_dir}/Assets/images.xcassets/DefaultSocietyLogo-Portrait.imageset", :verbose=>true
    FileUtils.cp Dir.glob(pathGraphicsResource + "/" + 'society_branding_iPhone*.png'), "#{@root_dir}/Assets/images.xcassets/DefaultSocietyLogo-Phone.imageset", :verbose=>true

    Kernel::system "./ios-icon-generator.sh #{pathGraphicsResource}/Icon-60@3x.png #{@root_dir}/Assets/images.xcassets/AppIcon.appiconset"
    #@splashScreenResizer.resizeSplashScreen(pathGraphicsResource, "#{@root_dir}/Assets/images.xcassets/")
  end

  def update_environment(env)
    if env == nil
      return "PROD"
    end
    if ["PROD","CERT","DEV"].include?(env.upcase)
      return env.upcase
    end
    return "PROD"
  end

  def setup_xcargs(app_short_code, app_name, bundle_identifier, profile_id, env, compile_timestamp, git_tag = "test")
    xcargs = ""
    xcargs << "APP_PROVISIONING_PROFILE=#{profile_id} "
    xcargs << "APP_SHORT_CODE=#{app_short_code} "
    xcargs << "APP_NAME=\"#{app_name}\" "
    xcargs << "APP_BUNDLE_ID=#{bundle_identifier} "
    xcargs << "ENVIRONMENT=#{env} "
    xcargs << "COMPILE_TIMESTAMP=\"#{compile_timestamp}\" "
    xcargs << "GIT_TAG=\"#{git_tag}\""
    return xcargs
  end

  def get_ipa_path_for_short_code(app_short_code, build_folder_path = "")
    ipa_files = build_folder_path == "" ? Dir["#{@root_dir}/build/*"] : Dir["#{@root_dir}/build/#{build_folder_path}/*"]
    ipa_file = ipa_files.select{|x| (x.include?(app_short_code) && x.include?(".ipa"))}[0]
    return ipa_file
  end
end
