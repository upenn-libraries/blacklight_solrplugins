
module BlacklightSolrplugins::XBrowse
  extend ActiveSupport::Concern

  def xbrowse
    facet_field = params[:id]
    # TODO: fill this out
    #@response = get_browse_facet_field_response(facet_field)
  end

  # @return [Blacklight::Solr::Response] the solr response
  def get_browse_facet_field_response(facet_field, user_params = params || {}, extra_controller_params = {})
    # TODO: fill this out
    query = search_builder.with(user_params).facet(facet_field)
    repository.search(query.merge(extra_controller_params))
  end

end
