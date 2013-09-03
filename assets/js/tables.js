(function (d3) {
    // Convert a table element/selector to an array
    // of arrays.
    var table_to_array = function (selector_or_el) {
        var rows = d3.select(selector_or_el)
            .selectAll("tr")
            .selectAll("th, td");

        var values = rows.map(function (row) {
            return row.map(function (cell) {
                var text = cell.innerHTML
                    .trim()
                    .replace(/\n/g, "\\n")
                    .replace(/&nbsp;/g, " ");
                return text;
            });
        });
        return values;
    };

    // Convert an array of arrays to CSV/TSV, using
    // a specified selector, which defaults a comma.
    var table_to_csv = function (rows, sep) {
        sep = sep || ",";
        var regex = new RegExp("\\" + sep);
        csv = rows.map(function (row) {
            return row.map(function (cell) {
                if (cell.match(regex)) {
                    cell = '"' + cell.replace('"', '\\"') + '"';    
                }
                return cell;
            }).join(sep);
        }).join("\n");
        return csv;
    };

    // Convert a CSV string to a data URI    
    var csv_to_uri = function (csv_str) {
        var b64 = btoa(unescape(encodeURIComponent(csv_str)));
        return "data:text/csv;base64," + b64;
    } 

    // Get all tables
    var tables = d3.selectAll("table");

    // Join CSV data to each table
    tables.data(tables[0].map(function (d, i) {
        var rows = table_to_array(d);
        return table_to_csv(rows);
    }));

    // Add a CSV download link to each table
    var links = tables.append("tfoot")
        .append("tr")
            .append("td")
                .attr("colspan", 10e3)
                .append("a");
    links.classed("csv-download", true)
        .attr("download", function (d, i) {
            return [ document.title.replace(/[^a-zA-Z0-9]+/g, "-"), "table", i+1 ].join("-") + ".csv";
        })
        .attr("href", function (d, i) {
            return csv_to_uri(d);
        })
        .text("Download as CSV");
}).call(this, d3);
