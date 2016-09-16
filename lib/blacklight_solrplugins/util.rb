
module BlacklightSolrplugins
  module Util

    ##
    # Takes an Array in which consecutive elements represent name-value pairs,
    # (which is how Solr serializes its NamedList structure into JSON)
    # and re-structures it as a Hash. Works recursively.
    #
    # This is more generic than Blacklight::Solr::Response::Facets#list_as_hash
    # which expects its input to be a hash of facet field name => array
    # and is not recursive.
    def self.named_list_as_hash(val)
      if val.is_a?(Array)
        return val.each_slice(2).each_with_object(ActiveSupport::HashWithIndifferentAccess.new) do |pair, hash|
          hash[pair[0]] = named_list_as_hash(pair[1])
        end
      end
      val
    end

  end
end
