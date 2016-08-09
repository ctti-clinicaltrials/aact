$(function() {


    $("#jsGrid").jsGrid({
        height: "80vh",
        width: "100%",
        filtering: true,
        inserting: false,
        editing: false,
        sorting: true,
        paging: true,
        autoload: true,
        pageSize: 10,
        pageButtonCount: 5,
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
            { name: "Table Name", type: "text", width: 95 },
            { name: "Column Name", type: "text", width: 105 },
            { name: "PRS Label", type: "text", width: 95},
            { name: "Data Type", type: "text", width: 90 },
            { name: "Max Length Used", type: "text", width: 40},
            { name: "Comments", type: "text", width: 270  },
            { name: "NLM Description", type: "text", width: 280 },
            { name: "NLM Req", type: "text", width: 50 },
            { name: "FDAAA Req", type: "text", width: 50 },
            { name: "Enumerations", type:"text", width: 100  },
            { type: "control", deleteButton: false, editButton: false }
        ]
    });
});
