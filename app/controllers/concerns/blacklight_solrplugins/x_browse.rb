
module BlacklightSolrplugins::XBrowse
  extend ActiveSupport::Concern

  def xbrowse
    target = params[:target]
    @facet = blacklight_config.facet_fields[params[:id]]
    # TODO: fill out
    facet_browse_solr_params = {
        "f.#{@facet.field}.facet.target": target,
        "f.#{@facet.field}.facet.offset": 0,
        "f.#{@facet.field}.facet.limit": 10
    }
    @response = get_facet_field_response(@facet.key, params, facet_browse_solr_params)
    @display_facet = @response.aggregations[@facet.key]
    @pagination = facet_paginator(@facet, @display_facet)
    respond_to do |format|
      # Draw the facet selector for users who have javascript disabled:
      format.html
      format.json
      # Draw the partial for the "more" facet modal window:
      format.js { render :layout => false }
    end
  end

end
