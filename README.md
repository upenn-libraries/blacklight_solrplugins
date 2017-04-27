
# BlacklightSolrplugins

A Rails engine that adds support for [solrplugins](https://github.com/upenn-libraries/solrplugins) to
Blacklight.

This contains:
- modifications to Blacklight to handle the custom facet payloads
  from solrplugins
- controller concerns and views for facet browsing showing cross-references and 
  for title browsing

## Solr Schema

TODO: link to schema defining _xfacet dynamic field types.

## How To Use This

Include this in your app's Gemfile.

```ruby
gem 'blacklight_solrplugins', :git => 'https://github.com/upenn-libraries/blacklight_solrplugins.git'
```

Modify your `CatalogController` or other relevant controller as follows:

```ruby
class CatalogController < ApplicationController

  # mixin to override BL controller actions to handle xbrowse
  include BlacklightSolrplugins::XBrowse

  # ...

  configure_blacklight do |config|
  
    # override Response class so xfacet payloads get interpreted correctly.
    # if you have your own or another Response subclass you want to use,
    # include the BlacklightSolrplugins::ResponseFacets module in it.
    config.response_model = BlacklightSolrplugins::Response

    # typically, you'll want both a facet field that behaves normally,
    # and an xfacet field for browsing.

    # this is a regular facet
    config.add_facet_field 'subject_topic_facet', label: 'Topic', limit: 20, index_range: 'A'..'Z'

    # facet marked as 'xfacet', suppressed from sidebar with 'show: false' (which is stock Blacklight)
    # rendered using 'rbrowse' (document-centric) view type
    # with fields defined for rbrowse display (which must be defined as either a show_field or 
    # index_field in Blacklight config)
    config.add_facet_field 'title_xfacet', label: 'Title', limit: 20, index_range: 'A'..'Z', 
        show: false, xfacet: true, xfacet_view_type: 'rbrowse', xfacet_rbrowse_fields: %w(published_display format)
        
    # facet marked as 'xfacet'; 'facet_for_filtering' is used to construct search URLs that filter on a corresponding regular facet.
    # rendered using 'xbrowse' (non-document-centric) view type
    # 'xfacet_value_helper' contains the name of a helper method for translating xfacet values to facet values (you must define this helper!)
config.add_facet_field 'subject_topic_xfacet', label: 'Topic', limit: 20, index_range: 'A'..'Z', show: false, xfacet: true,  xfacet_view_type: 'xbrowse', facet_for_filtering: 'subject_topic_facet', xfacet_value_helper: 'subject_xfacet_to_facet'

    # define search fields for xfacet browse: these MUST have the same name as the facet_fields above

    config.add_search_field('subject_topic_xfacet') do |field|
      field.label = 'Subject Heading Browse'
    end

    config.add_search_field('title_xfacet') do |field|
      field.label = 'Title Browse'
    end

end
```

Add this line to your `app/assets/javascripts/application.js` file; it
needs to go AFTER the require for blacklight.

```javascript
//= require blacklight_solrplugins/blacklight_solrplugins
```

Create a `SearchBuilder` if you don't already have one in your
project, and mix in `BlacklightSolrplugins::FacetFieldsQueryFilter` so
that xfacets only get included in the Solr query when necessary.

```
class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include BlacklightSolrplugins::FacetFieldsQueryFilter
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

  # xfacet fields should call #references to construct JSON
  to_field 'subject_topic_facet', extract_marc("600abcdq:610ab:611ab:630aa:650aa:653aa:654ab:655ab", :trim_punctuation => true) do |r, acc|
    acc.map! { |v| references(v) }
  end

end
```

## Running the test suite

Following other Blacklight gems, we use
[engine_cart](https://github.com/cbeer/engine_cart) to create a test
application for our engine.

You can run the test suite following the usual convention of running
rake without any arguments.

```
bundle exec rake
```

The first time you run it, engine_cart will do a bunch of work to
setup the test app, before running the tests. Subsequent runs should
be faster because this has already been done, so only the tests
themselves will run.
