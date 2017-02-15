$(function() {
  $("#activityJsGrid").jsGrid({
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
        pageSize: 80,
        controller: {
            loadData: function(filter) {
                return $.ajax({
                    type: "GET",
                    url: "/database_activity",
                    data: filter
                });
            }
        },
        fields: [
            { type: 'control', deleteButton: false, editButton: false },
            { name: 'id',                 width: 98, align: 'center' },
            { name: 'file_name',          type: "text", width: 180, align: 'center' },
            { name: 'log_date',           type: "text", width: 200 },
            { name: 'ip_address',         type: "text", width: 280 },
            { name: 'description',        type: "text", width: 450 },
        ]
    });
});
