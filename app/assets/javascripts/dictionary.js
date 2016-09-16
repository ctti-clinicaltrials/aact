$(function() {

  $("#jsGrid").jsGrid({
        height: "160vh",
        width: "90%",
        filtering: true,
        inserting: false,
        editing: false,
        sorting: true,
        paging: true,
        autoload: true,
        noDataContent: "...Loading...",
        searchButtonTooltip: "Search",
        clearFilterButtonTooltip: "Clear filter",
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
            { type: 'control', deleteButton: false, editButton: false },
            { name: 'nlm documentation', width: 22, align: 'center' },
//            { name: "db section", type: "select", width: 75, items: ['','Results','Protocol'] },
            { name: 'db section',         type: "text", width: 75 },
            { name: 'table',              type: "text", width: 180 },
            { name: 'column',             type: "text" },
            { name: 'data type',          type: "text", width: 70 },
            { name: 'xml source',         type: "text", width: 260 },
            { name: 'AACT contribution',  type: "text" },
            { name: 'CTTI Note',          type: "textarea", width: 260 },
            { name: 'AACT1 Variable',     type: "text" },
            { name: 'PRS Label',          type: "text" },
            { name: 'nlm required',       type: "checkbox" },
            { name: 'fdaaa required',     type: "checkbox" }
        ]
    });
});
