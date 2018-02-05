$(function() {

  $("#select-category").change(function() {
    cat=$(this).val()
    $("#meshGrid").jsGrid({
        height: "200vh",
        width: "100%",
        filtering: true,
        inserting: true,
        sorting: true,
        paging: false,
        autoload: true,
        noDataContent: "...Loading...",
        searchButtonTooltip: "Search",
        clearFilterButtonTooltip: "Clear filter",
        pageSize: 100,
        controller: {
            loadData: function(filter) {
                return $.ajax({
                    type: "GET",
                    url: "/category/get_terms/" + cat,
                    data: filter
                });
            }
        },
        fields: [
            { type: 'control', deleteButton: false, editButton: true, width: 16 },
            { name: 'type',          type: 'text', width: 40, align: 'center' },
            { name: 'term',          type: "text", width: 200 },
            { name: 'year',          type: 'text', width: 60 },
            { name: 'identifiers',   type: "text", width: 120 },
        ]
    })

    $("#studyGrid").jsGrid({
        height: "360vh",
        width: "100%",
        filtering: true,
        inserting: true,
        editing: true,
        sorting: true,
        paging: false,
        autoload: true,
        noDataContent: "...Loading...",
        searchButtonTooltip: "Search",
        clearFilterButtonTooltip: "Clear filter",
        pageSize: 100,
        controller: {
            loadData: function(filter) {
                return $.ajax({
                    type: "GET",
                    url: "/category/get_studies/" + cat,
                    data: filter
                });
            }
        },
        fields: [
            { type: 'control', deleteButton: false, editButton: true, width: 16 },
            { name: 'type',          type: 'text', width: 40, align: 'center' },
            { name: 'title',   type: "text", width: 200 },
            { name: 'start',    type: 'date', width: 80 },
            { name: 'end',  type: 'text', width: 80 },
        ]
    })

  })
})
