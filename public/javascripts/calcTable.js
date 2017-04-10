jQuery.fn.extend({
    calcTable: function(a) {
        var b = (1 == a.skipFirstColumn || 0 == a.skipFirstColumn) && a.skipFirstColumn,
            c = "undefined" != typeof a.totalText ? a.totalText : "Total",
            d = "" != typeof a.totalClass ? a.totalClass : "",
            e = $.parseHTML($("tbody", this).html().replace(/\s+/g, ""))[0].childElementCount,
            f = 1 == b ? e - 1 : e,
            g = new Array(f).fill(0),
            h = 1 == b ? 1 : 0,
            i = "";
        $.each($.parseHTML($("tbody", this).html().replace(/\s+/g, "")), function(a) {
            $.each($.parseHTML($(this).html()), function(a) {
                1 == b ? 0 != a && (g[a - h] += parseFloat($(this).html())) : g[a - h] += parseFloat($(this).html())
            })
        }), $.each(g, function(a) {
            i += "<td>" + g[a] + "</td>"
        }), $(this).append(1 == b ? "<tr class='" + d + "'><td>" + c + "</td>" + i + "</tr>" : "<tr>" + i + "</tr>")
    }
});