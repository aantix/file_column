require 'net/scp'
require 'lockfile'

module FileColumnAsset

  def self.append_features(base)
    super
    base.extend(ClassMethods)
  end

  module ClassMethods
    
    def sync_assets
      return if FileColumnAssetConfig.property[:host].blank?  # Can't replicate anything if there's no host
    
      # Look for all columns with a boolean "_synced" column
      cols = columns.find_all { |c| column_names.include?("#{c.name}_synced") }
      
      sync_to_host(cols)    
    end
    
    private

      # Take all of the columns with corresponding synced attributes, find the ones that
      #  haven't been replicated over, and do so according to the host params setup
      #  in the file_column.yml
      def sync_to_host(cols)
        max_channels = 3
    
        cols.each do |col|
      
          col_name = col.name
          sync_col = "#{col_name}_synced"
      
          unsynced_files = find_unsynced_entries(sync_col, max_channels)
      
          scp_channels = {}
          unsynced_files.each do |f|
        
            # Determine local and remote file paths for file.
            local_path  = local_file_path(f, col_name)
            remote_path = remote_file_path
        
            logger.info "LOCAL_PATH  = #{local_path}"
            logger.info "REMOTE_PATH = #{remote_path}"
        
            # Copy to host server
            logger.info "#{FileColumnAssetConfig.property[:host]}, #{FileColumnAssetConfig.property[:user]}, #{FileColumnAssetConfig.property[:password]}"
            scp_channels[f] = Net::SCP.upload!(FileColumnAssetConfig.property[:host], FileColumnAssetConfig.property[:user], local_path, remote_path, :password => FileColumnAssetConfig.property[:password], :recursive => true) if !FileColumnAssetConfig.property[:password].blank?
            scp_channels[f] = Net::SCP.upload!(FileColumnAssetConfig.property[:host], FileColumnAssetConfig.property[:user], local_path, remote_path, :recursive => true) if FileColumnAssetConfig.property[:password].blank?
        
          end
          
          process_channels(scp_channels, col_name, sync_col)
      
        end
    
      end
  
      # E.g. /home/jonesj/var/www/current/public/
      def remote_file_path
        FileColumnAssetConfig.property[:document_root]
      end
  
      # E.g. /Users/jim/myapp/public/product/image/0000/0001/
      def local_file_path(f, col_name)
        r = f.send("#{col_name}_relative_dir")        
        File.join(RAILS_ROOT, 'public', name.underscore, col_name, r)
      end
  
      # Looks through the channel hash to see if any uploads have completed.
      #  If they have, go ahead and mark the db entry as complete.  
      #  Return final number of free channels.
      def process_channels(channels, col_name, sync_col)
        completed = false
        
        while !completed
          completed = true
        
          channels.each do |f, channel|
          
            if !channel.active?
              local_path = local_file_path(f, col_name)
      
              # Mark the file as synced
              f[sync_col] = true
              f.save
      
              # Delete from the current web server because the file
              #  will now be referenced from the asset server.
              FileUtils.rm_r local_path, :force => true
            
              # Remove the channel from the hash
              channels.delete(channel)
              
            else
              completed = false
            end
          
          end # channels.each          
          sleep(5) if !completed      
        end
        
      end
  
      def find_unsynced_entries(sync_col, max_channels = 10)
        find(:all, :conditions => ["#{sync_col} = ?", false], :limit => max_channels)
      end
    
  end # ClassMethods
  
end