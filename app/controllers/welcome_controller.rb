require 'open-uri'
require 'image_optim'
require 'fileutils'

class WelcomeController < ApplicationController
  def index
    #Dir.foreach('public/tmp/') {|f| fn = File.join('public/tmp/', f); File.delete(fn) if f != '.' && f != '..'}
    Dir.glob("public/tmp/*").
      select{|f| File.mtime(f) < (Time.now - (60*120)) }.
      each{|f| File.delete(f) }

    image = params[:i]
    extension = File.extname(image)

    acceptable_extensions = [".jpg", ".gif", ".png"]

    return @json = "{\"error\":\"only jpg, png, and gif can be resized\"}" if !acceptable_extensions.include?( extension.downcase )

    value = ""; 8.times{value  << (65 + rand(25)).chr}
    tmp_image = "public/tmp/#{value}#{extension}"

    open(tmp_image, 'wb') do |file|
      file << open(image).read
    end

    before_filesize = (File.size(tmp_image) * 0.001).floor

    image_optim = ImageOptim.new
    image_optim = ImageOptim.new(:pngout => false)
    image_optim = ImageOptim.new(:nice => 10)

    image_optim.optimize_image!(tmp_image)

    after_filesize = (File.size(tmp_image) * 0.001).floor

    tmp_image = "http://mf.contropa.com:3000/tmp/#{value}#{extension}"

    @json = "[{\"dest\":\"#{tmp_image}\",\"src_size\":#{before_filesize},\"dest_size\":#{after_filesize}}]"
  end

end
