module Bucket
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
  
  def self.api
    @api ||= Radiator::Api.new(CRAB_BUCKET_RADIATOR_OPTIONS)
  end
  
  def self.stream
    @stream ||= Radiator::Stream.new(CRAB_BUCKET_RADIATOR_OPTIONS)
  end
end
