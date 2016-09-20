module ActiveRecordExtension
  extend ActiveSupport::Concern
end

# Include the extension
ActiveRecord::Base.send(:include, ActiveRecordExtension)