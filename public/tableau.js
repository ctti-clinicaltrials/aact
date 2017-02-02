(function () {
    var myConnector = tableau.makeConnector();

    myConnector.getSchema = function (schemaCallback) {
      var cols = [
        { id : "nct_id", alias : "name", dataType : tableau.dataTypeEnum.string },
        { id : "overall_status", alias : "overall_status", dataType : tableau.dataTypeEnum.string },
        { id : "study_type", alias : "study_type", dataType : tableau.dataTypeEnum.string },
        { id : "start_date", alias : "start_date", dataType : tableau.dataTypeEnum.date },
        { id : "primary_completion_date", alias : "primary_completion_date", dataType : tableau.dataTypeEnum.date },
        { id : "phase", alias : "phase", dataType : tableau.dataTypeEnum.string },
        { id : "acronym", alias : "acronym", dataType : tableau.dataTypeEnum.string },
        { id : "brief_title", alias : "brief_title", dataType : tableau.dataTypeEnum.string },
      ];

      var tableInfo = {
        id : "studies",
        alias : "Clinical Trials",
        columns : cols
      };

      schemaCallback([tableInfo]);

    };

    myConnector.getData = function (table, doneCallback) {
      var criteria = JSON.parse(tableau.connectionData)
      if (criteria.term) {
        var apiCall = "https://aact-dev.herokuapp.com/api/v1/studies?term="+criteria.term;
      }

      $.getJSON(apiCall, function(resp) {
            var tableData = [];
            for (var i = 0, len = resp.length; i < len; i++) {
              src=resp[i]["_source"]
              tableData.push({
                "nct_id": src['nct_id'],
                "overall_status": src['overall_status'],
                "study_type": src['study_type'],
                "start_date": src['start_date'],
                "primary_completion_date": src['primary_completion_date'],
                "phase": src['phase'],
                "acronym": src['acronym'],
                "brief_title": src['brief_title'],
              });
            }

            table.appendRows(tableData);
            doneCallback();
       });
    };

    tableau.registerConnector(myConnector);

$(document).ready(function () {
    $("#submitButton").click(function () {
        var criteria = {
            term: $('#term').val(),
        };
        tableau.connectionData =  JSON.stringify(criteria);
        tableau.connectionName = "Select Clinical Trials";
        tableau.submit();
    });
});

})();

