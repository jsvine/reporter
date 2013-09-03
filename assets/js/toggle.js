(function (d3) {

    var $body = d3.select(document.body);
    var code_toggles = d3.selectAll(".code-toggle");

    var toggle_code = function (d, i) {
        var show_code = !$body.classed("code-toggle-on");
        $body.classed("code-toggle-on", show_code);
        window.scroll(0, 0);
    };

    code_toggles.on("click", toggle_code);

}).call(this, d3);
