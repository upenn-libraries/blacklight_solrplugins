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
  # @param [Hash] params search parameters
  # @param [String] target
  # @param [String] ref reference point for browsing when direction is set
  # @param [String] dir direction, either 'back' or 'forward'
  # @param [Numeric] per_page number of records per page
  # @return [Array] [response, document_list, display_facet, display_facet_window]
  def search_results_with_xfacets(params, facet, target, ref, dir, per_page)
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

    facet_target = ref || target || ''

    (response, document_list) = search_results(params.merge(:rows => 0)) do |search_builder|
      additional_params = {
          "f.#{facet.field}.facet.target": JSON.dump(facet_target),
          "f.#{facet.field}.facet.sort": 'index',
          "f.#{facet.field}.facet.offset": offset,
          "f.#{facet.field}.facet.limit": per_page + 2 }
      if ref
        additional_params["f.#{facet.field}.facet.target.strict"] = true
      end
      search_builder.merge(additional_params)
    end

    display_facet = response.aggregations[facet.key]
    display_facet_window = display_facet.window(per_page, expected_pos_in_results)

    return [response, document_list, display_facet, display_facet_window]
  end

  # action
  def xbrowse
    target = params[:q]
    ref = params[:ref] # reference point, used for paging
    dir = params[:dir]
    per_page = params.fetch(:per_page, blacklight_config.default_per_page).to_i

    @facet = blacklight_config.facet_fields[params[:id]]

    (@response, @document_list, @display_facet, @display_facet_window) =
        search_results_with_xfacets(params, @facet, target, ref, dir, per_page)

    respond_to do |format|
      format.html
      format.json
    end
  end

  def xbrowse_documents
    # TODO: hook up to document-centric facets
  end

end
