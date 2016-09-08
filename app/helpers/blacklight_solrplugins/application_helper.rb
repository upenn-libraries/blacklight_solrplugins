module BlacklightSolrplugins
  module ApplicationHelper

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

  end
end
