module BlacklightSolrplugins
  class Engine < ::Rails::Engine
    isolate_namespace BlacklightSolrplugins

    engine_name "blacklight_solrplugins"

    initializer 'blacklight_solrplugins.helpers' do |app|
      ActionView::Base.send :include, BlacklightSolrplugins::ApplicationHelper
    end

    config.autoload_paths += %W(
      #{config.root}/app/presenters
      #{config.root}/app/controllers/concerns
      #{config.root}/app/models/concerns
    )

  end
end
