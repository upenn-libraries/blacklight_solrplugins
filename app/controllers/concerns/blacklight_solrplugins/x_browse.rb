require 'json'

# Controller concern (mix-in) that provides
# the action methods for browsing xfacets
module BlacklightSolrplugins::XBrowse
  extend ActiveSupport::Concern

  def xbrowse
    target = params[:target]
    @facet = blacklight_config.facet_fields[params[:id]]
    (@response, @document_list) = search_results(params.merge(:rows => 0)) do |search_builder|
      search_builder.merge({
        "f.#{@facet.field}.facet.target": JSON.dump(target),
        "f.#{@facet.field}.facet.sort": 'index',
        "f.#{@facet.field}.facet.offset": 0,
        "f.#{@facet.field}.facet.limit": 25 })
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
