
# What Blacklight extracts from the Solr response and passes to
# FacetItem's constructor as value for the 'hits' argument, may not be
# a number, but instead, a payload for cross reference fields. So we
# simply monkey patch FacetItem to handle this.
#
# An alternative approach would be to have code everywhere in
# Blacklight::Solr::Response::Facets examine the facet payload. That
# would actually be more meaningful, but it's also a more invasive set
# of changes.

# monkey patch
class Blacklight::Solr::Response::Facets::FacetItem

  def initialize *args
    super(*args)
    if self[:hits] && !self[:hits].is_a?(Numeric)
      # re-structure the data we received as 'hits'
      self[:payload] = BlacklightSolrplugins::Util.named_list_as_hash(self[:hits])
      self[:hits] = self[:payload][:count]
    end
  end

end

