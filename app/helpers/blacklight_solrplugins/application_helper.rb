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
      args.reject! { |arg| %w(dir ref target).member? arg }
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

    # override Blacklight::ConfigurationHelperBehavior#search_fields
    # search_form.js detects the attributes on option elements
    # and makes the form submit do the right thing
    def search_fields
      super.map do |field_entry|
        key = field_entry[1]
        field_def = blacklight_config.search_fields[key]
        # replace entries whose field objects define 'action'
        if field_def.action
          [field_def.label, field_def.key, { 'data-action' => field_def.action } ]
        else
          field_entry
        end
      end
    end

  end
end
