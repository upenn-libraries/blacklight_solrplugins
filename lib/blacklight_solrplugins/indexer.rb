
require 'json'

# Helper methods to format values going into solr for xfacet fields
module BlacklightSolrplugins::Indexer

  # namespace for our 'private' methods
  module Validators

    # @param [Hash] h
    def self.validate_hash(h)
      if h.is_a?(Hash)
        h.keys.each do |key|
          ok = (key == "filing") && h[key].is_a?(String)
          ok ||= (key == "prefix") && h[key].is_a?(String)
          return false if !ok
        end
        return true
      end
      return false
    end

    def self.validate_multipart_string(s)
      return s.is_a?(String) || validate_hash(s)
    end
  end

  # returns stringified JSON object to use as a value for xfacet fields
  # @param [String|Hash] raw raw string value for this facet
  # @param [Hash] refs references data structure
  def references(raw, refs: nil)
    if !Validators.validate_multipart_string(raw)
      raise "'raw' is not a string or hash representing multipart string: #{raw}"
    end
    if refs
      refs.values.each do |val|
        if !Validators.validate_multipart_string(val)
          raise "ref value is not a string or hash representing multipart string: #{val}"
        end
      end
    end
    hash = Hash.new
    hash['raw'] = raw
    hash['refs'] = refs if refs
    JSON.generate(hash)
  end

end
