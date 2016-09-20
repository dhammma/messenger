module ActiveRecordExtension
  extend ActiveSupport::Concern

  def to_api_response
    model_info = {}
    model_info[:id] = id
    model_info[:type] = self.class.to_s

    model_info
  end
end

# Include the extension
ActiveRecord::Base.send(:include, ActiveRecordExtension)