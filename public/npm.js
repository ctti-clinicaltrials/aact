(function() {
    // Create the connector object
    var myConnector = tableau.makeConnector();

    // Define the schema
    myConnector.getSchema = function(schemaCallback) {
        var cols = [{
            id: "name",
            alias: "name",
            dataType: tableau.dataTypeEnum.string
        }, {
            id: "downloads",
            alias: "downloads",
            dataType: tableau.dataTypeEnum.int
        }, {
            id: "date",
            alias: "date",
            dataType: tableau.dataTypeEnum.string
        }];

        var packages = tableau.connectionData.split(";")[0].replace(/\s+/g, '').split(',');

        schemas = packages.map(function(name){
            return {
                id: name,
                alias: name,
                columns: cols

            }
        })

        schemaCallback(schemas);
    };

    // Download the data
    myConnector.getData = function(table, doneCallback) {

        var dates = tableau.connectionData.split(';')[1];
        var apiCall = "https://api.npmjs.org/downloads/range/"+dates+"/" + table.tableInfo.id;

        tableau.log("dates: " + dates);
        tableau.log("api call: " + apiCall);

        $.getJSON(apiCall, function(resp) {
            tableau.log("resp: " + resp);
            var dates = resp.downloads;

            table.appendRows(dates.map(function(date){
                return {
                    name: table.tableInfo.id,
                    date: date.day,
                    downloads: date.downloads
                }
            }));
            doneCallback();
        });
    };

    tableau.registerConnector(myConnector);

    // Create event listeners for when the user submits the form
    $(document).ready(function() {
        $('.date').datepicker({
            todayBtn: true,
            format: 'yyyy-mm-dd'
        });

        $("#submitButton").click(function() {
            var packages = $('#packages').val().trim();
            var startDate = $('#startDate').val().trim();
            var endDate = $('#endDate').val().trim();
            if (packages && startDate && endDate) {
                tableau.connectionData = packages + ";" + startDate + ":" + endDate; // Use this variable to pass data to your getSchema and getData functions
                tableau.connectionName = "NPM Packages"; // This will be the data source name in Tableau
                tableau.submit(); // This sends the connector object to Tableau
            } else {
                alert("Enter a valid date for each date range and packages.");
            }
        });
    });
})();
