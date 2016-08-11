$(function() {


    $("#jsGrid").jsGrid({
        height: "160vh",
        width: "100%",
        filtering: true,
        inserting: false,
        editing: false,
        sorting: true,
        paging: false,
        autoload: true,
        // pageSize: 10,
        // pageButtonCount: 5,
        deleteConfirm: "Do you really want to delete client?",
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
            { name: "Table Section", type: "text" },
            { name: "Table Name", type: "text" },
            { name: "Column Name", type: "text" },
            { name: "AACT Contribution", type: "text" },
            { name: "XML Source", type: "text" },
            { name: "NLM Documentation", type: "text", width: 120 },
            { name: "AACT1 Variable", type: "text" },
            { name: "PRS Label", type: "text"},
            { name: "CTTI Note", type: "text", width: 260 },
            { name: "Data Type", type: "text" },
            { name: "# of rows in table", type: "text" },
            { name: "Distinct Column Values", type: "text" },
            { name: "Max Length Allowed", type: "text" },
            { name: "Max Length Current", type: "text" },
            { name: "Min Length Current", type: "text" },
            { name: "Avg. Length Current", type: "text" },
            { name: "Common Values", type: "text" },
            { name: "NLM Required", type: "text" },
            { name: "FDAAA Required", type: "text" }
        ]
    });
});
