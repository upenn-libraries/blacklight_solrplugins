require 'json'

# Controller concern (mix-in) that provides functionality for handling xfacet searches
module BlacklightSolrplugins::XBrowse
  extend ActiveSupport::Concern

  def calc_offset_and_expected_pos(dir)
    offset = 1
    expected_pos_in_results = 1
    if dir == 'forward'
      offset = 0
      expected_pos_in_results = 0
    elsif dir == 'back'
      offset += per_page
      expected_pos_in_results = per_page + 1
    end
    [offset, expected_pos_in_results]
  end

  def per_page
    params.fetch(:per_page, blacklight_config.default_per_page).to_i
  end

  def xfacet_query_params(xfacet, search_params)
    target = search_params[:q]
    ref = search_params[:ref] # reference point, used for paging
    dir = search_params[:dir]

    if xfacet.xfacet_view_type == 'xbrowse'
      doc_centric = false
    elsif xfacet.xfacet_view_type == 'rbrowse'
      doc_centric = true
    end

    # over-fetch items so we can determine whether to display prev/next buttons.
    # when paging forward => ref point is last item, which should be at position 0 in new results
    # when paging back => ref point is first item, which should be at last position in new results

    offset, _ = calc_offset_and_expected_pos(dir)

    if doc_centric
      facet_target = target.present? ? target : ''
      # ref is a composite key (target/targetDoc) to disambiguate target
      if ref
        pieces = ref.split('|', 2)
        ref = pieces[0]
        facet_target = pieces[1]
      end
    else
      facet_target = ref || target || ''
    end

    additional_params = {
      # distrib.singlePass is required in order to make solrplugins
      # include documents in the doc-centric xfacet payloads when running
      # distributed Solr
      'distrib.singlePass' => 'true',
      "f.#{xfacet.field}.facet.target" => JSON.dump(facet_target),
      "f.#{xfacet.field}.facet.sort" => 'index',
      "f.#{xfacet.field}.facet.offset" => offset,
      "f.#{xfacet.field}.facet.limit" => per_page + 2 }
    if ref
      additional_params["f.#{xfacet.field}.facet.target.strict"] = true
    end
    if doc_centric
      additional_params["f.#{xfacet.field}.facet.targetDoc"] = ref || ''
    end
    additional_params
  end

  # @return [Blacklight::Configuration::FacetField] xfacet field object
  #   that corresponds to the search field, if it exists
  def get_xfacet_for_search_field
    facet_field = blacklight_config.facet_fields[params[:search_field]]
    facet_field if (facet_field && facet_field.xfacet)
  end

  # override Blacklight::SearchHelper#search_results
  #
  # This handles xbrowse/rbrowse searches
  def search_results(search_params)
    xfacet = get_xfacet_for_search_field
    if xfacet
      params_without_q = search_params.dup
      params_without_q.delete(:q)

      (response, document_list) = super(params_without_q.merge(:rows => 0)) do |search_builder|
        additional_params = xfacet_query_params(xfacet, search_params)
        search_builder.merge(additional_params)
      end

      [response, document_list]
    else
      super(search_params)
    end
  end

  # override Blacklight::SearchHelper#get_facet_field_response
  # so that Solr queries for facet pop-up take into account xfacet searches
  def get_facet_field_response(facet_field, user_params = params || {}, extra_controller_params = {})
    xfacet = get_xfacet_for_search_field
    if xfacet
      params_without_q = user_params.dup
      params_without_q.delete(:q)

      query_params = xfacet_query_params(xfacet, user_params)

      query = search_builder.with(params_without_q).merge(query_params).facet(facet_field)
      repository.search(query.merge(extra_controller_params))
    else
      super(facet_field, user_params, extra_controller_params)
    end
  end

  # override Blacklight::Catalog#index
  #
  # It sucks to duplicate code from #index but we do so for 2 reasons:
  # 1) the return values from #search_results are different for xfacet searches
  # and need to be handled, 2) we use different top-level view templates
  # for rbrowse/xbrowse functionality because it's too crazy to shoehorn
  # what we want into stock Blacklight search results views and partials
  def index
    xfacet = get_xfacet_for_search_field
    if xfacet
      @facet = xfacet

      template = case xfacet.xfacet_view_type
                   when 'rbrowse'
                     'catalog/rbrowse'
                   when 'xbrowse'
                     'catalog/xbrowse'
                 end

      (@response, @document_list) = search_results(params)

      @display_facet = @response.aggregations[xfacet.key]
      @display_facet_window =
        BlacklightSolrplugins::FacetFieldWindow.new(@display_facet, per_page, calc_offset_and_expected_pos(params[:dir])[1])

      respond_to do |format|
        format.html { render :template => template }
        format.rss  { render :layout => false }
        format.atom { render :layout => false }
        format.json do
          @presenter = Blacklight::JsonPresenter.new(@response,
                                                     @document_list,
                                                     facets_from_request,
                                                     blacklight_config)
        end
        additional_response_formats(format)
        document_export_formats(format)
      end

    else
      super
    end
  end

end
