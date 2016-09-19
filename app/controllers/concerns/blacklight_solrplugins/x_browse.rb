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

  # action
  def xbrowse
    target = params[:target]
    ref = params[:ref] # reference point, used for paging
    dir = params[:dir]
    per_page = params.fetch(:per_page, blacklight_config.default_per_page).to_i

    offset = 0
    if dir == 'back'
      offset = per_page
    elsif dir == 'forward'
      offset = -1
    end

    facet_target = ref || target || ''

    @facet = blacklight_config.facet_fields[params[:id]]
    (@response, @document_list) = search_results(params.merge(:rows => 0)) do |search_builder|
      additional_params = {
          "f.#{@facet.field}.facet.target": JSON.dump(facet_target),
          "f.#{@facet.field}.facet.sort": 'index',
          "f.#{@facet.field}.facet.offset": offset,
          "f.#{@facet.field}.facet.limit": per_page }
      if dir
        # TODO: this is throwing things off
        #additional_params["f.#{@facet.field}.facet.target.strict"] = true
      end
      search_builder.merge(additional_params)
    end
    @display_facet = @response.aggregations[@facet.key]
    respond_to do |format|
      format.html
      format.json
    end
  end

  def xbrowse_documents
    # TODO: hook up to document-centric facets
  end

end
