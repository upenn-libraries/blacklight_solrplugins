
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

    # Takes the facet items with which this object was initially populated,
    # and treats them as doc centric facets, re-writing them so that there's
    # one document per facet_item.
    def process_doc_centric_items!
      is_doc_centric = items.any? { |item| item.docs.size > 0 }
      # flatten the nested structure for doc-centric facet items
      if is_doc_centric
        @items = items.map do |facet_item|
          term_metadata = facet_item.term_metadata
          facet_item.docs.map do |doc|
            BlacklightSolrplugins::FacetItem.new(value: facet_item.value, payload: { 'count' => 1, 'termMetadata' => term_metadata, 'docs' => [ doc ] })
          end
        end.flatten
      end
    end

  end

end
