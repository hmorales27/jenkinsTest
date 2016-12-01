require_relative '../FastlaneFunctions.rb'
require 'pry'


FF = FastlaneFunctions.new
binding.pry
FF.update_urban_airship('A','B','C','D')
FF.update_images("#{ENV["PATH_GRAPHICS_RESOURCE"]}/LANCET")
binding.pry
puts FF.get_app_short_codes
