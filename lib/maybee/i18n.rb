files = Dir[File.join(File.dirname(__FILE__), '../locales/*.yml')]
I18n.load_path.concat(files)

