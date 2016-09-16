
# BlacklightSolrplugins

A Rails engine that adds support for [solrplugins](https://github.com/upenn-libraries/solrplugins) to
Blacklight.

This contains:
- modifications to Blacklight to handle cross-reference facet fields
- stock controllers/views for facet browsing showing cross-references

## How To Use This

Include this in your app's Gemfile.

```ruby
gem 'blacklight_solrplugins', :git => 'https://github.com/upenn-libraries/blacklight_solrplugins.git'
```

Configure routing for the xfacet browsing pages, in `config/routes.rb`:

```ruby
Rails.application.routes.draw do
  # declare xbrowsable concern
  concern :xbrowsable, BlacklightSolrplugins::Routes::XBrowsable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    # add concern to this resource
    concerns :xbrowsable
  end
end
```

Modify your `CatalogController` or other relevant controller as follows:

```ruby
class CatalogController < ApplicationController

  # mixin 'xbrowse' action
  include BlacklightSolrplugins::XBrowse

  # ...

  # override Blacklight::Controller
  def search_state
    @search_state ||= BlacklightSolrplugins::SearchState.new(params, blacklight_config)
  end

  # ...

  configure_blacklight do |config|
  
    # override Response class so xfacet payloads get interpreted correctly
    config.response_model = BlacklightSolrplugins::Response

    # typically, you'll want both a facet field that behaves normally,
    # and an xfacet field for browsing.

    # regular facet
    config.add_facet_field 'subject_topic_facet', label: 'Topic', limit: 20, index_range: 'A'..'Z'
    # xfacet. "show: false" suppresses it from sidebar.
    config.add_facet_field 'subject_topic_xfacet', label: 'Topic', limit: 20, index_range: 'A'..'Z', show: false, xfacet: true
  end
```

That's it!

## Indexing

This gem also provides code to facilitate indexing xfacet fields, even
though indexing is not properly part of Blacklight. If you're using
Traject, change your indexer model as follows:

```ruby
class MarcIndexer < Blacklight::Marc::Indexer

  # add this line to provide #references method
  include BlacklightSolrplugins::Indexer

  # xfacet fields should call #references
  to_field 'subject_topic_facet', extract_marc("600abcdq:610ab:611ab:630aa:650aa:653aa:654ab:655ab", :trim_punctuation => true) do |r, acc|
    acc.map! { |v| references(v) }
  end

end
```
