module FileColumnAssetConfig
  mattr_accessor :property
  
  class Config  
    def initialize
    	@config = YAML.load_file("config/file_column.yml")[RAILS_ENV]
    end
      
    def [](k)
      @config[k.to_s]
    end    
  
  end
  
  def self.property
    @property ||= Config.new
  end
  
end