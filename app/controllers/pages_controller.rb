class PagesController < ApplicationController
  require 'open-uri'
  require 'uri'

  def new
  end

  def create
    uri = URI(params[:url])
    page = Nokogiri::HTML(open(params[:url]))

    @logos = find_logo(page,uri)
    p @logos.inspect
  end

  private

  # Return array of potential logo urls
  def find_logo(page,uri)
    @srcs = []
    @srcs += find_anchor_root_logos(page,uri)
    #@srcs += find_logo_class_id_logos(page,uri)
    return @srcs
  end

  def find_anchor_root_logos(page,uri)
    # Works with
    #http://www.wayfair.com/Lighting-C215735.html
    #http://www.superbrightleds.com/
    #http://www.buylighting.com/
    #http://revolights.com/
    #http://www.overstock.com/
    #http://tartecosmetics.com/tarte-item-lights-camera-lashes-mascara
    #http://www.homedepot.com/webapp/catalog/servlet/ContentView?pn=led_light_bulbs_energy_efficient_way_to_light_your_home_HT_BG_EL&storeId=10051&langId=-1&catalogId=10053
    #http://www.homedepot.com/webapp/catalog/servlet/ContentView?pn=led_light_bulbs_energy_efficient_way_to_light_your_home_HT_BG_EL&storeId=10051&langId=-1&catalogId=10053
    #http://www.joann.com/lights/
    #http://www.lightingbuff.com/
    #http://www.lowes.com/cd_Light+Bulb+Buying+Guide_167459951_
    #http://www.bhphotovideo.com/buy/Tungsten-Lights/ci/2247/N/4037060760
    #http://www.lampsusa.com/lighting-fixtures-2.aspx?gclid=COaPrZiuiLoCFaU9Qgod6mEAqg
    #http://www.spencersonline.com/decor_lighting/
    #http://www.switchlightingco.com/
    #http://www.save-on-crafts.com/brbryearroun.html
    #http://www.led-lights-online.com/
    #http://www.ultrapoi.com/
    #http://www.superiorlighting.com/
    #http://www.bulbamerica.com/
    #http://www.servicelighting.com/
    #http://www.affordablequalitylighting.com/rope-light/
    #http://www.rei.com/learn/expert-advice/mountain-bike.html
    
    roots = build_possible_roots(uri.host)
    
    # Find anchors that point to root page
    # page.css('a[href]').select { |anchor| roots.include? anchor['href'] }.
    anchors = page.css('a').select { |anchor| (anchor.attribute('href') && roots.include?(anchor['href'])) }
    
    # Find if they have images
    srcs = []
    anchors.each do |anchor|
      if images = anchor.css('img[src]')
        images.each do |image|
          image_src = image['src']
          # If it does not start with http:// and www. we need to add the host
          if !/^(http|https|www|\/\/)/.match(image_src)
            if image_src.start_with?('/')
              image_src = 'http://' + uri.host + image_src
            else
              image_src = 'http://' + uri.host + '/' + image_src
            end
          end
          srcs << image_src 
        end
      end
    end

    return srcs
  end

  def build_possible_roots(host)
    roots = ['/','index.html']
    http_root = 'http://' + host 
    http_root_slash_finished = 'http://' + host + '/'
    roots << http_root << http_root_slash_finished
    unless host.start_with?('www.')
      www_root = 'www.' + host 
      http_www_root = 'http://www.' + host 
      www_root_back_slashed = 'www.' + host + '/'
      http_www_root_back_slashed = 'http://www.' + host + '/'
      roots << www_root << http_www_root << www_root_back_slashed << http_www_root_back_slashed
    end
    p "roots are" + roots.inspect
    return roots
  end
end
