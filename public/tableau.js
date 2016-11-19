(function () {
    var myConnector = tableau.makeConnector();

    myConnector.getSchema = function (schemaCallback) {
      var cols = [
        { id : "nct_id", alias : "name", dataType : tableau.dataTypeEnum.string },
        { id : "overall_status", alias : "overall_status", dataType : tableau.dataTypeEnum.string },
        { id : "study_type", alias : "study_type", dataType : tableau.dataTypeEnum.string },
        { id : "phase", alias : "phase", dataType : tableau.dataTypeEnum.string },
        { id : "enrollment", alias : "enrollment", dataType : tableau.dataTypeEnum.string },
        { id : "enrollment_type", alias : "enrollment_type", dataType : tableau.dataTypeEnum.string },
        { id : "source", alias : "source", dataType : tableau.dataTypeEnum.string },
        { id : "first_received_date", alias : "first_received_date", dataType : tableau.dataTypeEnum.date },
        { id : "received_results_disposit_date", alias : "received_results_disposit_date", dataType : tableau.dataTypeEnum.date },
        { id : "completion_date_type", alias : "completion_date_type", dataType : tableau.dataTypeEnum.string },
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
      if (!criteria.meshTerm) {
        if (!criteria.organization) {
          var apiCall = "http://aact-dev.herokuapp.com/api/v1/studies";
        } else {
          var apiCall = "http://aact-dev.herokuapp.com/api/v1/studies?organizataion="+criteria.organization;
          //var apiCall = "http://aact-dev.herokuapp.com/api/v1/studies?organization="+criteria.organization+"?with_related_records=true&with_related_organizations=true";
        }
      } else {
        var apiCall = "http://aact-dev.herokuapp.com/api/v1/studies?meshTerm="+criteria.meshTerm;
        //var apiCall = "http://aact-dev.herokuapp.com/api/v1/studies?meshTerm="+criteria.meshTerm+"?with_related_records=true&with_related_organizations=true";
      }

      $.getJSON(apiCall, function(resp) {
            var tableData = [];
            for (var i = 0, len = resp.length; i < len; i++) {
              tableData.push({
                "nct_id": resp[i].nct_id,
                "overall_status": resp[i].overall_status,
                "study_type": resp[i].study_type,
                "phase": resp[i].phase,
                "source": resp[i].source,
                "enrollment": resp[i].enrollment,
                "enrollment_type": resp[i].enrollment_type,
                "first_received_date": resp[i].first_received_date,
                "completion_date_type": resp[i].completion_date_type,
                "received_results_disposit_date": resp[i].received_results_disposit_date,
                "brief_title": resp[i].brief_title,
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
            organization: $('#organization').val().trim(),
            meshTerm: $('#meshTerm').val().trim(),
        };
        tableau.connectionData =  JSON.stringify(criteria);
        tableau.connectionName = "Select Clinical Trials";
        tableau.submit();
    });
});

})();

