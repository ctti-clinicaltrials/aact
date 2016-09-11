$(function() {

  $("#jsGrid").jsGrid({
        height: "160vh",
        width: "90%",
        filtering: true,
        inserting: false,
        editing: false,
        sorting: true,
        paging: false,
        autoload: true,
        noDataContent: "...Loading...",
        // pageSize: 10,
        // pageButtonCount: 5,
        controller: {
            loadData: function(filter) {
                return $.ajax({
                    type: "GET",
                    url: "/definitions",
                    data: filter
                });
            }
        },
        fields: [
          { type: "control", deleteButton: false, editButton: false },
            { name: "db section", type: "text" },
            { name: "table", type: "text" },
            { name: "column", type: "text" },
            { name: "AACT contribution", type: "text" },
            { name: "xml source", type: "text" },
            { name: "nlm documentation", type: "text", width: 120 },
            { name: "AACT1 Variable", type: "text" },
            { name: "PRS Label", type: "text"},
            { name: "CTTI Note", type: "text", width: 260 },
            { name: "data type", type: "text" },
            { name: "# of rows in table", type: "text" },
            { name: "Max Length Allowed", type: "text" },
            { name: "Max Length Current", type: "text" },
            { name: "Min Length Current", type: "text" },
            { name: "Avg Length Current", type: "text" },
            { name: "nlm required", type: "text" },
            { name: "fdaaa required", type: "text" }
        ]
    });
});
