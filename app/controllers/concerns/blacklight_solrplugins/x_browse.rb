require 'json'

# Controller concern (mix-in) that provides
# the action methods for browsing xfacets
module BlacklightSolrplugins::XBrowse
  extend ActiveSupport::Concern

  # override from Blacklight::Controller.
  # Since this gem effectively extends the notion of a "search action"
  # to include xbrowse pages, we need this method to return the right links
  # for facets sidebar, query constraints panel, and maybe other places.
  def search_action_path(*args)
    if params[:action] == 'xbrowse'
      url_for(*args)
    else
      super(*args)
    end
  end

  # Performs a search using the specified parameters,
  # setting additional Solr arguments for retrieving xfacet information.
  #
  # @param [Blacklight::Configuration::FacetField] facet
  # @param [Hash] search_params search parameters
  # @param [String] target
  # @param [String] ref reference point for browsing when direction is set
  # @param [String] dir direction, either 'back' or 'forward'
  # @param [Numeric] per_page number of records per page
  # @param [Boolean] doc_centric 'true' if making a request for doc-centric facets.
  # @return [Array] [response, document_list, display_facet, display_facet_window]
  def search_results_with_xfacets(search_params, facet, target, ref, dir, per_page, doc_centric)
    # over-fetch items so we can determine whether to display prev/next buttons.
    # when paging forward => ref point is last item, which should be at position 0 in new results
    # when paging back => ref point is first item, which should be at last position in new results
    offset = 1
    expected_pos_in_results = 1
    if dir == 'forward'
      offset = 0
      expected_pos_in_results = 0
    elsif dir == 'back'
      offset += per_page
      expected_pos_in_results = per_page + 1
    end

    if doc_centric
      # hack to circumvent RSolr calling #compact on params hash: pass a space char
      facet_target = target.present? ? target : ' '
      # ref is a composite key (target/targetDoc) to disambiguate target
      if ref
        pieces = ref.split('|', 2)
        ref = pieces[0]
        facet_target = pieces[1]
      end
    else
      facet_target = ref || target || ''
    end

    (response, document_list) = search_results(search_params.merge(:rows => 0)) do |search_builder|
      additional_params = {
          "f.#{facet.field}.facet.target": doc_centric ? facet_target : JSON.dump(facet_target),
          "f.#{facet.field}.facet.sort": 'index',
          "f.#{facet.field}.facet.offset": offset,
          "f.#{facet.field}.facet.limit": per_page + 2 }
      if ref
        additional_params["f.#{facet.field}.facet.target.strict"] = true
      end
      if doc_centric
        # hack to circumvent RSolr calling #compact on params hash: pass a space char
        additional_params["f.#{facet.field}.facet.targetDoc"] = ref || ' '
      end
      search_builder.merge(additional_params)
    end

    display_facet = response.aggregations[facet.key]
    display_facet_window =
        BlacklightSolrplugins::FacetFieldWindow.new(display_facet, per_page, expected_pos_in_results)

    return [response, document_list, display_facet, display_facet_window]
  end

  # generic browse method called by actions hooked up to routes
  def browse(_params, doc_centric)
    target = _params.delete(:q)
    ref = _params[:ref] # reference point, used for paging
    dir = _params[:dir]
    per_page = _params.fetch(:per_page, blacklight_config.default_per_page).to_i

    @facet = blacklight_config.facet_fields[_params[:id]]

    (@response, @document_list, @display_facet, @display_facet_window) =
        search_results_with_xfacets(_params, @facet, target, ref, dir, per_page, doc_centric)

    respond_to do |format|
      format.html
      format.json
    end
  end

  # action: cross-ref facet browsing
  def xbrowse
    _params = params.dup
    return browse(_params, false)
  end

  # action: doc-centric facet browsing
  def rbrowse
    _params = params.dup
    return browse(_params, true)
  end

end
