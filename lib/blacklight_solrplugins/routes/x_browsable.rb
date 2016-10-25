# frozen_string_literal: true
module BlacklightSolrplugins
  module Routes
    class XBrowsable
      def initialize(defaults = {})
        @defaults = defaults
      end

      def call(mapper, options = {})
        options = @defaults.merge(options)
        mapper.get "xbrowse/:id", action: 'xbrowse', as: 'xbrowse'
        mapper.get "rbrowse/:id", action: 'rbrowse', as: 'rbrowse'
      end
    end
  end
end
