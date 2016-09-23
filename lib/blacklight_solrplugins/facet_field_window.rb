
module BlacklightSolrplugins

  # This class is a wrapper around FacetField
  # to support Solr client-side 'windowing': since we over-fetch
  # in order to support prev/next functionality, we have to
  # trim ends and interpret solrplugin's end-windows in order to
  # properly determine what to show.
  class FacetFieldWindow

    attr :facetfield, :size, :items, :has_previous, :has_next

    # @param [BlacklightSolrplugins::FacetField] facetfield
    # @param [Numeric] size the size of the window
    # @param [Numeric] expected_pos_in_results the position we expect to find our target;
    #   we use this to compare to actual target_offset value returned from Solr.
    def initialize(facetfield, size, expected_pos_in_results)
      @facetfield = facetfield
      @size = size
      @expected_pos_in_results = expected_pos_in_results

      via_target = expected_pos_in_results == 1
      via_back_button = expected_pos_in_results == size + 1
      via_next_button = expected_pos_in_results == 0

      if via_target
        start = facetfield.target_offset
      elsif via_back_button
        start = facetfield.target_offset - size
        start = start < 0 ? 0 : start
      elsif via_next_button
        if facetfield.target_offset + size < facetfield.items.size
          start = facetfield.target_offset + 1
        else
          start = facetfield.items.size - size
        end
        start = start < 0 ? 0 : start
      end

      is_full_window = facetfield.items.size == size + 2

      @items = facetfield.items[start .. start + size - 1]

      if via_target
        @has_previous = facetfield.target_offset >= 1
        @has_next = facetfield.target_offset <= 1 && is_full_window
      elsif via_back_button
        @has_previous = facetfield.target_offset == expected_pos_in_results
        @has_next = is_full_window
      elsif via_next_button
        @has_previous = is_full_window
        @has_next = (facetfield.target_offset == expected_pos_in_results) && (facetfield.items.size == size + 2)
      end
    end

  end

end
