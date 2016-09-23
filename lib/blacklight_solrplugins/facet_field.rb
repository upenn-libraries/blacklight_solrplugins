
module BlacklightSolrplugins

  # FacetField subclass to handle custom facet payloads in Solr response data
  class FacetField < Blacklight::Solr::Response::FacetField
    attr_reader :name, :items
    def initialize name, items, options = {}
      @name = name
      @items = items
      @options = options
    end

    # Note that superclass has a #count? method to indicate
    # whether sort order is 'count'. This method returns the
    # top-level count for the xfacet field.
    def count
      @options[:count]
    end

    def target_offset
      @options[:target_offset]
    end

    # @return [FacetFieldWindow] window object for this facet
    def window(size, expected_pos_in_results)
      FacetFieldWindow.new(self, size, expected_pos_in_results)
    end

  end

end
