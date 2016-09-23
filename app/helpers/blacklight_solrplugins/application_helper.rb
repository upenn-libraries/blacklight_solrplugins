module BlacklightSolrplugins
  module ApplicationHelper

    # OBSOLETE: xfacets shouldn't be used for display.
    # override from Blacklight::FacetsHelperBehavior.
    # item can be a string or a FacetItem, as this used for both rendering
    # the value from a URL facet param AND the facets sidebar.
    def facet_display_value(field, item)
      facet_config = facet_configuration_for_field(field)
      if facet_config[:xfacet]
        if item.is_a?(String)
          filing, prefix = item.split("|")
          return prefix.to_s + filing.to_s
        else
          _self = item.payload[:self]
          if _self
            return (_self[:prefix] || "") + (_self[:filing] || "")
          end
        end
      else
        super(field, item)
      end
    end

    def xfacet_record_count(count)
      "#{count} record#{count > 1 ? 's' : ''}"
    end

    # returns a search URL (NOT an xbrowse URL)that filters on this facet value.
    # we need this because we can't use #path_for_facet since that
    # calls our overridden #search_action_path
    # TODO: it'd be better to save the old #search_action_path somehow and call that
    # but I couldn't figure out how to do that.
    def search_path_for_xfacet(xfacet_field, facet_value)
      # NOTE that we use the facet_for_filtering field, NOT the xfacet field,
      # when adding a query constraint to search URL
      args = search_state.add_facet_params_and_redirect(xfacet_field['facet_for_filtering'], facet_value)
      search_action_url(args)
    end

    def xbrowse_previous_link(facetwindow)
      first = facetwindow.items.first
      if first
        url_for(search_state.params_for_search(ref: first.value, dir: "back"))
      end
    end

    def xbrowse_next_link(facetwindow)
      last = facetwindow.items.last
      if last
        url_for(search_state.params_for_search(ref: last.value, dir: "forward"))
      end
    end

  end
end
