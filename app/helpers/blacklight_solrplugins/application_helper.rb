module BlacklightSolrplugins
  module ApplicationHelper

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

    # returns a URL that filters on this facet value
    def path_for_xfacet(xfacet_field, facet_value)
      # NOTE that we use the facet_for_filtering field, NOT the xfacet field,
      # when adding a new query constraint
      path_for_facet(xfacet_field['facet_for_filtering'], facet_value)
    end

    def xbrowse_show_previous_link?(facet)
      # TODO
      true
    end

    def xbrowse_show_next_link?(facet)
      # TODO
      true
    end

    def xbrowse_previous_link(facet)
      first = facet.items.first
      if first
        url_for(search_state.params_for_search(ref: first.value, dir: "back"))
      end
    end

    def xbrowse_next_link(facet)
      last = facet.items.last
      if last
        url_for(search_state.params_for_search(ref: last.value, dir: "forward"))
      end
    end

  end
end
