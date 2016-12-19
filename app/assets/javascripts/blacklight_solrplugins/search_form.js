
Blacklight.onLoad(function() {
    function removeXfacetParams(formElement) {
        // remove params for existing search
        $(formElement).find("input[name='dir']").remove();
        $(formElement).find("input[name='ref']").remove();
    }


    $(".search-query-form").on("submit", function(event) {
        var form = event.currentTarget;

        removeXfacetParams(form);

        var selected = $(form).find("#search_field option:selected").first();
        if(selected.length > 0) {
            var x_action = selected.attr("data-action");
            if (x_action) {
                $(form).attr("action", x_action);
            }
        }
    });

    // compatibility with blacklight_advanced_search: adv search form should
    // always clear out xfacet params
    $("form.advanced").on("submit", function(event) {
        removeXfacetParams(form);
    });

});
