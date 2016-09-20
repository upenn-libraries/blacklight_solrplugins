
class BlacklightSolrplugins::SearchState < Blacklight::SearchState

  DELIMITER = "|"

  # OBSOLETE: xfacets shouldn't be used for display.
  # override from Blacklight::SearchState.
  # combine filing + prefix into a single value to use for
  # URL param. TODO: is this the best way, or should we have separate
  # fields (which would require more invasive customization of BL)?
  def facet_value_for_facet_item item
    if !(item.is_a?(String) ||item.is_a?(Numeric))
      if item.try(:payload)
        _self = item.payload[:self]
        if _self
          return _self[:filing] + (_self[:prefix] ? DELIMITER + _self[:prefix] : "")
        end
      end
    end
    super(item)
  end

end
