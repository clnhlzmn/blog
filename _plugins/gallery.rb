
#install ImageMagick
#add gem "mini_magick" to your site's Gemfile
#run gem install mini_magick
#add <site source>/gallery folder with images
#add gallery/ to exclude list in your site's _config.yml
#run jekyll build

require 'mini_magick'

module GalleryGenerator
    class GalleryGenerator < Jekyll::Generator
        def generate(site)
            if File.directory?(File.join(site.source, "gallery"))
            image = MiniMagick::Image.open(
                "https://images.unsplash.com/photo-1516295615676-7ae4303c1c63"
            )
            print image
        end
    end
end
