$(function() {

  $("#jsGrid").jsGrid({
        height: "160vh",
        width: "100%",
        filtering: true,
        inserting: false,
        editing: false,
        sorting: true,
        paging: true,
        autoload: true,
        noDataContent: "...Loading...",
        searchButtonTooltip: "Search",
        clearFilterButtonTooltip: "Clear filter",
        pageSize: 40,
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
            { name: 'nlm doc',            width: 38, align: 'center' },
            { name: 'db section',         type: "text", width: 75 },
            { name: 'table',              type: "text", width: 180 },
            { name: 'column',             type: "text", width: 180 },
            { name: 'data type',          type: "text", width: 70 },
            { name: 'source',             type: "text", width: 260 },
            { name: 'CTTI Note',          type: "text", width: 360 },
            { name: 'enumerations',       type: "text", width: 200 },
        ]
    });
});
