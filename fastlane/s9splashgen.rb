#!/usr/bin/env ruby
# encoding : utf-8

require 'rubygems'
require 'rmagick'
include Magick

class SplashScreenResizer
  # arguments processing
  def resizeSplashScreen(img_name, export_path)

    device = 'universal'

    # only iOS 7.0 and above
    sizes = [
      {
        idiom: 'iphone',
        name: 'Default@1x~iphone.png',
        orientation: 'portrait',
        width: 375,
        height: 667,
        scale: 1,
        location: 'SplashScreenIPhone.imageset',
        image_name: 'Default-568h@2x.png'
      },
      {
        idiom: 'iphone',
        name: 'Default@2x~iphone.png',
        orientation: 'portrait',
        width: 375,
        height: 667,
        scale: 2,
        location: 'SplashScreenIPhone.imageset',
        image_name: 'Default-568h@2x.png'
      },
      {
        idiom: 'iphone',
        name: 'Default@3x~iphone.png',
        orientation: 'portrait',
        width: 414,
        height: 736,
        scale: 3,
        location: 'SplashScreenIPhone.imageset',
        image_name: 'Default-568h@2x.png'
      },
      {
        idiom: 'iphone',
        name: 'Default@1x~iphone.png',
        orientation: 'portrait',
        width: 375,
        height: 667,
        scale: 1,
        location: 'SplashScreenIPadPortrait.imageset',
        image_name: 'Default-568h@2x.png'
      },
      {
        idiom: 'iphone',
        name: 'Default@2x~iphone.png',
        orientation: 'portrait',
        width: 375,
        height: 667,
        scale: 2,
        location: 'SplashScreenIPadPortrait.imageset',
        image_name: 'Default-568h@2x.png'
      },
      {
        idiom: 'iphone',
        name: 'Default@3x~iphone.png',
        orientation: 'portrait',
        width: 414,
        height: 736,
        scale: 3,
        location: 'SplashScreenIPadPortrait.imageset',
        image_name: 'Default-568h@2x.png'
      },
      {
        idiom: 'ipad',
        name: 'Default@1x~ipad.png',
        orientation: 'portrait',
        width: 768,
        height: 1024,
        scale: 1,
        location: 'SplashScreenIPadPortrait.imageset',
        image_name: 'Default-Portrait@2x~ipad.png'
      },
      {
        idiom: 'ipad',
        name: 'Default@2x~ipad.png',
        orientation: 'portrait',
        width: 768,
        height: 1024,
        scale: 2,
        location: 'SplashScreenIPadPortrait.imageset',
        image_name: 'Default-Portrait@2x~ipad.png'
      },
      {
        idiom: 'ipad',
        name: 'Default@1x~ipad.png',
        orientation: 'landscape',
        width: 1024,
        height: 768,
        scale: 1,
        location: 'SplashScreenIPadLandscape.imageset',
        image_name: 'Default-Landscape@2x~ipad.png'
      },
      {
        idiom: 'ipad',
        name: 'Default@2x~ipad.png',
        orientation: 'landscape',
        width: 1024,
        height: 768,
        scale: 2,
        location: 'SplashScreenIPadLandscape.imageset',
        image_name: 'Default-Landscape@2x~ipad.png'
      },
    ]

    pad_landscape_image = ImageList.new(img_name + '/Default-Landscape@2x~ipad.png')
    pad_portrait_image = ImageList.new(img_name + '/Default-Portrait@2x~ipad.png')
    phone_image = ImageList.new(img_name + '/Default-568h@2x.png')

    sizes.each do |s|

      img = nil
      if s[:image_name] == 'Default-568h@2x.png'
        img = phone_image
      elsif s[:image_name] == 'Default-Portrait@2x~ipad.png'
        img = pad_portrait_image
      else
        img = pad_landscape_image
      end

      if device == 'universal' || s[:idiom].start_with?(device)
        width = s[:scale]*s[:width]
        height = s[:scale]*s[:height]
        scaled_img = img.resize_to_fill(width, height)
        filename = export_path + "#{s[:location]}/" + s[:name]
        puts filename
        log(width, height, s[:scale], filename)
        scaled_img.write(filename)
      end
    end
  end
  def log(width, height, scale, filename)
    s = "#{width/scale}x#{height/scale}"
    s.insert(0, ' '*(9 - s.length))
    f = "#{scale}x"
    fs = "#{width}x#{height}"
    fs.insert(0, ' '*(9 - fs.length))
    puts "#{s}(#{f}) -> #{fs}: #{filename}"
  end

end
