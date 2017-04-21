module BlacklightSolrplugins
  module HelperBehavior

    def xfacet_record_count(count)
      "#{count} record#{count > 1 ? 's' : ''}"
    end

    # returns a search URL (NOT an xbrowse URL)that filters on this facet value.
    # we need this in order to use the 'facet_for_filtering' config option on facet field definitions
    def search_path_for_xfacet(xfacet_field, facet_value)
      # NOTE that we use the facet_for_filtering field, NOT the xfacet field,
      # when adding a query constraint to search URL
      args = search_state.add_facet_params_and_redirect(xfacet_field['facet_for_filtering'], facet_value)
      args.reject! { |arg| %w(dir ref target search_field q).member? arg }
      search_action_url(args)
    end

    def xbrowse_previous_link(facetwindow, doc_centric: false)
      first = facetwindow.items.first
      if first
        if doc_centric
          ref = first.docs[0]['id'] + '|' + first.value
        else
          ref = first.value
        end
        url_for(search_state.params_for_search(ref: ref, dir: "back"))
      end
    end

    def xbrowse_next_link(facetwindow, doc_centric: false)
      last = facetwindow.items.last
      if last
        if doc_centric
          ref = last.docs[0]['id'] + '|' + last.value
        else
          ref = last.value
        end
        url_for(search_state.params_for_search(ref: ref, dir: "forward"))
      end
    end

    def render_xbrowse_result(facet_item, facet)
      facet_value = facet_item.value
      if facet['xfacet_value_helper']
        facet_value = send(facet['xfacet_value_helper'].to_sym, facet_item.value)
      end
      link_to(facet_item.value, search_path_for_xfacet(facet, facet_value), :class=>"facet_select")
    end

    # render the link and its text content, for an rbrowse result item
    # @param [BlacklightSolrplugins::FacetItem] facet_item
    # @param [Blacklight::ShowPresenter] doc_presenter
    def render_rbrowse_result(facet_item, doc_presenter)
      link_to(facet_item.value, solr_document_path(doc_presenter.field_value('id')))
    end

    def render_rbrowse_display_fields(facet, doc_presenter)
      (facet.xfacet_rbrowse_fields || []).map do |fieldname|
        render_rbrowse_display_field(fieldname, doc_presenter)
      end.compact.join("\n").html_safe
    end

    def render_rbrowse_display_field(fieldname, doc_presenter)
      if doc_presenter.field_value(fieldname).present?
        field = blacklight_config.show_fields[fieldname] || blacklight_config.index_fields[fieldname]
        label = field ? field.label : fieldname
        "<dt>#{label}:</dt><dd>#{doc_presenter.field_value(fieldname)}</dd>"
      end
    end

  end
end
