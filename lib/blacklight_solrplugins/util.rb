
module BlacklightSolrplugins
  module Util

    def self.named_list_as_hash(val)
      if val.is_a?(Array)
        return val.each_slice(2).each_with_object(ActiveSupport::HashWithIndifferentAccess.new) do |pair, hash|
          hash[pair[0]] = named_list_as_hash(pair[1])
        end
      end
      val
    end

  end
end
