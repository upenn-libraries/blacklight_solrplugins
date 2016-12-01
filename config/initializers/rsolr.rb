
module RSolr::Uri

  # patch so that params with empty string values are NOT removed
  def self.params_to_solr(params, escape = true)

    return URI.encode_www_form(params.reject{|k,v| k.to_s.empty?}) if escape

    # escape = false if we are here
    mapped = params.map do |k, v|
      if v.class == ::Array
        params_to_solr(v.map { |x| [k, x] }, false)
      else
        "#{k}=#{v}"
      end
    end
    mapped.join("&")
  end

end
