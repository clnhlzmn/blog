
#install ImageMagick
#add gem "mini_magick" to your site's Gemfile
#run gem install mini_magick
#add <site source>/gallery folder with images
#add gallery/ to exclude list in your site's _config.yml
#add gallery.rb to your site's _plugins folder
#run jekyll build

require 'fileutils'
require 'json'
require 'mini_magick'
require 'pathname'

module GalleryGenerator
    
    class SourceGallery
        def initialize(path, name)
            @path = path
            @name = name
        end
        def to_s
            "#gallery {@name} at #{@path}"
        end
        def path
            @path
        end
        def name
            @name
        end
    end

    class GalleryGenerator < Jekyll::Generator
    
        def full_size_html(name, date)
            "---\n"                                             \
            "layout: post\n"                                    \
            "title: #{name}\n"                                  \
            "date: #{date.strftime("%Y-%m-%d %H:%M:%S")}\n"     \
            "exclude: true\n"                                   \
            "---\n"                                             \
            "<img src=\"{{site.baseurl}}/assets/img/1024/#{name}\"></img>\n"
        end
        
        def gallery_html(id, image_data)
            "<div id='#{id}_pig'></div>\n"                                                          \
            "<script src='{{site.baseurl}}/assets/js/pig.min.js'></script>\n"                   \
            "<script>\n"                                                                        \
            "var #{id}_pig = new Pig(\n"                                                        \
            "    #{image_data.to_json()},\n"                                                    \
            "    {\n"                                                                           \
            "        containerId: '#{id}_pig',\n"                                                   \
            "        classPrefix: '#{id}_pig',\n"                                                   \
            "        urlForSize: function(filename, size) {\n"                                  \
            "            return '{{site.baseurl}}/assets/img/' + size + '/' + filename;\n"      \
            "        },\n"                                                                      \
            "        onClickHandler: function(filename) {\n"                                    \
            "            window.location.href = '{{site.baseurl}}/assets/html/' + filename;\n"  \
            "        }\n"                                                                       \
            "    }\n"                                                                           \
            ").enable();\n"                                                                     \
            "</script>"
        end
        
        #read the image data from the _includes folder
        def get_image_data()
            image_data = []
            #read image_data if existing
            if File.exists?(File.join(@includes_path, "gallery_data.html"))
                File.open(File.join(@includes_path, "gallery_data.html"), 'r') { |file|
                    #get array of image data (drop 'var imageData = ' and ';')
                    image_data = JSON.parse(file.read)
                }
            end
            image_data
        end
        
        #read images that require processing from gallery
        def get_images(gallery_path)
            images = {}
            #determine list of image names
            Dir.entries(gallery_path).each { |file_name| 
                full_image_path = File.join(gallery_path, file_name)
                begin 
                    images[file_name] = MiniMagick::Image.open(full_image_path)
                rescue
                    #not an image
                    #puts "jekyll-pig: " << full_image_path << " is not an image"
                end
            }
            images
        end
        
        def get_image_date(gallery_path, image_name, image)
            image_date = nil
            begin
                exif_date = image.exif['DateTimeOriginal']
                if exif_date == nil
                    #no exif date, try to get from file name
                    image_date = Time.strptime(image_name, "%Y-%m-%d")
                else
                    #try to get the image date from exif
                    image_date = Time.strptime(exif_date, "%Y:%m:%d %H:%M:%S")
                end
            rescue
                #get the date from file if possible
                image_date = File.mtime(File.join(gallery_path, image_name))
            end
            image_date
        end
        
        #create thumbnails and fullsize image assets, and create full size html page for a given image
        def process_image(gallery_path, image_name, image)
            #puts "jekyll-pig: processing " << image_name
            #create thumbs
            [1024, 500, 250, 100, 20].each { |size|
                resized_img_path = File.join(@img_path, size.to_s, image_name)
                if not File.exists? resized_img_path
                    image.resize("x" + size.to_s)
                    size_out_path = File.join(@img_path, size.to_s)
                    FileUtils.mkdir_p size_out_path unless File.exists? size_out_path
                    image.write(resized_img_path)
                end
            }
            image_date = get_image_date(gallery_path, image_name, image)
            #create full size html text
            full_size_html = full_size_html(image_name, image_date)
            #create full size image page html for each image
            full_size_html_path = File.join(@html_path, image_name + ".html")
            if not File.exists? full_size_html_path
                File.open(full_size_html_path, 'w') { |file| 
                    file.write(full_size_html) 
                }
            end
        end
        
        def get_paths
            @assets_path = File.join(@site.source, "assets")
            @img_path = File.join(@assets_path, "img")
            @html_path = File.join(@assets_path, "html")
            @includes_path = File.join(@site.source, "_includes")
        end
        
        def get_galleries
            galleries = []
            config_galleries = Jekyll.configuration({})['galleries']
            if config_galleries != nil
                config_galleries.each do |gallery|
                    full_path = File.join(@site.source, gallery['path'])
                    if File.directory?(full_path)
                        galleries << SourceGallery.new(full_path, gallery['name'])
                    end
                end
            else
                default_gallery_path = File.join(@site.source, 'gallery')
                if File.directory?(default_gallery_path)
                    galleries << SourceGallery.new(default_gallery_path, 'gallery')
                end
            end
            galleries
        end
        
        def make_output_paths
            FileUtils.mkdir_p @assets_path unless File.exists? @assets_path
            FileUtils.mkdir_p @img_path unless File.exists? @img_path
            FileUtils.mkdir_p @html_path unless File.exists? @html_path
            FileUtils.mkdir_p @includes_path unless File.exists? @includes_path
        end
        
        def generate(site)
            @site = site
            get_paths()
            make_output_paths()
            galleries = get_galleries()
            galleries.each do |gallery|
                image_data = []
                images = get_images(gallery.path)
                images.each do |image_name, image|
                    #create thumbs, full size, and html assets for each image
                    process_image(gallery.path, image_name, image)
                    #get image date
                    image_date = get_image_date(gallery.path, image_name, image)
                    #append data to image_data array
                    image_data << 
                        {
                            'datetime' => image_date.to_s,
                            'filename' => image_name,
                            'aspectRatio' => image.width.to_f / image.height
                        }
                end
                File.open(File.join(@includes_path, "#{gallery.name}.html"), 'w') { |file|
                    image_data = image_data.sort_by { |data| data['datetime'] }
                    file.write(gallery_html(gallery.name, image_data))
                }
            end
            #check for gallery directory
            #if File.directory?(@gallery_path)
                #array for holding image data for later
                #image_data = get_image_data()
                #hash for holding images from mini_magick, file name is key
                #images = get_images(image_data)
                #make output path(s)
                #FileUtils.mkdir_p @assets_path unless File.exists? @assets_path
                #FileUtils.mkdir_p @img_path unless File.exists? @img_path
                #FileUtils.mkdir_p @html_path unless File.exists? @html_path
                #FileUtils.mkdir_p @includes_path unless File.exists? @includes_path
                #for each image
                #images.each { |image_name, image|
                    #process_image(image_data, image_name, image)
                #}
                #create gallery_data include file
                #File.open(File.join(@includes_path, "gallery_data.html"), 'w') { |file|
                    #image_data = image_data.sort_by { |data| data['datetime'] }
                    #file.write(image_data.to_json())
                #}
            #else 
                #puts "jekyll-pig: no gallery at " << @gallery_path
            #end
        end
    end
end
