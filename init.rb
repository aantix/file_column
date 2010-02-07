# plugin init file for rails
# this file will be picked up by rails automatically and
# add the file_column extensions to rails

require 'file_column'
require 'file_column_asset'
require 'file_compat'
require 'file_column_helper'
require 'validations'

ActiveRecord::Base.send(:include, FileColumn)
ActiveRecord::Base.send(:include, FileColumnAsset)
ActionView::Base.send(:include, FileColumnHelper)
ActiveRecord::Base.send(:include, FileColumn::Validations)