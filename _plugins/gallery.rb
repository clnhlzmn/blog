
#add <source>/gallery folder with images
#add gallery/ to exclude list in _config.yml
module GalleryGenerator
    class GalleryGenerator < Jekyll::Generator
        def generate(site)
            print File.directory?(File.join(site.source, "gallery"))
        end
    end
end
