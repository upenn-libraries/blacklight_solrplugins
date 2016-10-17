
Blacklight.onLoad(function() {
    $(".search-query-form").on("submit", function(event) {
        var form = event.currentTarget;
        var selected = $(form).find("#search_field option:selected").first();
        if(selected.length > 0) {
            var x_action = selected.attr("x-action");
            if (x_action) {
                $(form).attr("action", x_action);
                // TODO: should it be possible to specify q AND target?
                $(form).find("input[name='q']").attr("name", "target");
            }
        }
    });
});
