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
    roots = build_possible_roots(uri.host)
    
    # Find anchors that point to root page
    # page.css('a[href]').select { |anchor| roots.include? anchor['href'] }.
    anchors = page.css('a').select { |anchor| (anchor.attribute('href') && roots.include?(anchor['href'])) }

    # Find if they have images
    srcs = []
    anchors.each do |anchor|
      if images = anchor.css('img[src]')
        images.each do |image|
          srcs << image['src']
        end
      end
    end

    return srcs
  end

  def build_possible_roots(host)
    roots = ['/']
    http_root = 'http://' + host 
    roots << http_root
    unless host.start_with?('www.')
      www_root = 'www.' + host 
      http_www_root = 'http://www.' + host 
      roots << www_root << http_www_root
    end
    return roots
  end
end
