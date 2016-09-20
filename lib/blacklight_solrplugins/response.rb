
module BlacklightSolrplugins

  # Response subclass for handling custom facet payloads.
  class Response < Blacklight::Solr::Response

    # Override Blacklight::Solr::Response::Facets#facet_field_aggregations
    # to populate the FacetField and FacetItem objects with
    # additional data from the xfacet payload
    def facet_field_aggregations
      results = super

      xfacet_field_names = blacklight_config.facet_fields.select { |k,v| v.xfacet }.keys

      results_xfacets = list_as_hash(facet_fields.select { |k,v| xfacet_field_names.member?(k) }).each_with_object({}) do |(facet_field_name, values), hash|
        items = []

        # xfacet payload format will vary depending on solr query params

        next if !values.member?('terms')

        BlacklightSolrplugins::Util.named_list_as_hash(values['terms']).each do |display_value, payload|

          i = BlacklightSolrplugins::FacetItem.new(value: display_value, hits: payload['count'], payload: payload)

          # solr facet.missing serialization
          if display_value.nil?
            i.label = I18n.t(:"blacklight.search.fields.facet.missing.#{facet_field_name}", default: [:"blacklight.search.facets.missing"])
            i.fq = "-#{facet_field_name}:[* TO *]"
          end

          items << i
        end

        options = facet_field_aggregation_options(facet_field_name)

        # merge in additional fields from the xfacet payload
        options.merge!({ :count => values['count'], :target_offset => values['target_offset']})

        hash[facet_field_name] = BlacklightSolrplugins::FacetField.new(facet_field_name,
                                                                       items,
                                                                       options)

        if blacklight_config and !blacklight_config.facet_fields[facet_field_name]
          # alias all the possible blacklight config names..
          blacklight_config.facet_fields.select { |k,v| v.field == facet_field_name }.each do |key,_|
            hash[key] = hash[facet_field_name]
          end
        end
      end

      results.merge(results_xfacets)
    end

  end
end
