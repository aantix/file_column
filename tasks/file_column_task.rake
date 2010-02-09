namespace :file_column do

  desc "Create file_column asset server YML file in the config direcory"

  task(:setup) do

    puts "Creating #{RAILS_ROOT}/config/file_column.yml" 

    quotes = File.new("#{RAILS_ROOT}/config/file_column.yml", "w") 

    quotes.puts( 
      "development:\n  host: assets.example.com\n  user: jimj\n  document_root: /var/www/rails/myapp/current/public/system\n\n" \
      "production:\n  host: assets.example.com\n  user: jimj\n  document_root: /var/www/rails/myapp/current/public/system\n\n" \
      "test:\n  host: assets.example.com\n  user: jimj\n  document_root: /var/www/rails/myapp/current/public/system"
    ) 

  end 

end