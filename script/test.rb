require 'yaml'

scrape_config =  YAML.load_file( "scrape_config.yml" )
puts scrape_config
