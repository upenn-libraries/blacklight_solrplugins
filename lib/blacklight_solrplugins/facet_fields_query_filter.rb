
module BlacklightSolrplugins

  # Mix-in for SearchBuilder that overrides #facet_fields_to_include_in_request
  # so that xfacet fields don't get included unless we're doing a browse search
  # that uses it.
  module FacetFieldsQueryFilter

    # TODO: Blacklight allows setting the 'if' argument in facet field
    # definitions to a lambda to determine if field is displayed (though it
    # still gets sent in the Solr query). This isn't supported for
    # 'include_in_request', but if it was, it would eliminate the need for this
    # FacetFieldsQueryFilter module. I should submit a PR to Blacklight for
    # this feature.
    def facet_fields_to_include_in_request
      super.select do |field_name,facet|
        if facet.xfacet
          # this assumes search field name matches xfacet field name
          if search_field && (facet.field == search_field.field)
            true
          else
            false
          end
        else
          true
        end
      end
    end

  end
end

