module BlacklightSolrplugins

  # Overrides for BlacklightHelper.
  # This should be included in the main app's ApplicationHelper
  module BlacklightOverride

    # override Blacklight::ConfigurationHelperBehavior#search_fields
    # search_form.js detects the attributes on option elements
    # and makes the form submit do the right thing
    def search_fields
      super.map do |field_entry|
        key = field_entry[1]
        field_def = blacklight_config.search_fields[key]
        # replace entries whose field objects define 'action'
        if field_def.action
          [field_def.label, field_def.key, { 'data-action' => field_def.action } ]
        else
          field_entry
        end
      end
    end

  end
end
