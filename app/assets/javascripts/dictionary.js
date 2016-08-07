// //
// $( document ).ready(function() {
//
//   var clients = [
//           { "Name": "Otto Clay", "Age": 25, "Country": 1, "Address": "Ap #897-1459 Quam Avenue", "Married": false },
//           { "Name": "Connor Johnston", "Age": 45, "Country": 2, "Address": "Ap #370-4647 Dis Av.", "Married": true },
//           { "Name": "Lacey Hess", "Age": 29, "Country": 3, "Address": "Ap #365-8835 Integer St.", "Married": false },
//           { "Name": "Timothy Henson", "Age": 56, "Country": 1, "Address": "911-5143 Luctus Ave", "Married": true },
//           { "Name": "Ramona Benton", "Age": 32, "Country": 3, "Address": "Ap #614-689 Vehicula Street", "Married": false }
//       ];
//
//   // var clients = [
//   //         { "Table Name": "ARM_GROUPS",
//   //         "Column Name": "arm_group_label",
//   //         "PRS Label": "Arm or Group Label",
//   //         "Data Type": 2,
//   //         "Max Length Used": 62,
//   //         "NLM Description": "Study Document Definitions:Arm Label - the short name used to identify the arm. (Limit: 62 characters).* (FDAAA)Examples: • Metformin • Lifestyle counseling • Sugar pill Group/Cohort Label - the short name used to identify the group. (Limit: 62 characters) * Examples: • Statin dose titration • Chronic kidney disease, no anemia • No treatment Results Document Definitions: Arm/Group * Definition: Arms or comparison groups in a trial Arm/Group Title * : Label used to identify the arm or comparison group. Minimum length is 4 characters. Titles shorter than the minimum are unlikely to sufficiently describe the arm or comparison group. Examples: fluoxetine; sertraline; drug-eluting stent; placebo (Limit: >=4 and <=62 characters) ",
//   //         "NLM Required": true,
//   //         "FDAAA Required": false,
//   //         "Enumerations": "Sample Content" },
//   //
//   //         { "Table Name": "ARM_GROUPS",
//   //         "Column Name": "arm_group_type",
//   //         "PRS Label": "Arm Type",
//   //         "Data Type": 2,
//   //         "Max Length Used": 20,
//   //         "NLM Description": "Study Document Definitions: Arm Type * (FDAAA)- select one Experimental Active Comparator Placebo Comparator Sham Comparator  No intervention Other",
//   //         "NLM Required": true,
//   //         "FDAAA Required": false,
//   //         "Enumerations": "Sample Content" },
//   //
//   //         { "Table Name": "AUTHORITIES",
//   //         "Column Name": "authority_id",
//   //         "PRS Label": "Primary key for AUTHORITIES",
//   //         "Data Type": 1,
//   //         "Max Length Used": 6,
//   //         "NLM Description": "",
//   //         "NLM Required": false,
//   //         "FDAAA Required": false,
//   //         "Enumerations": "Sample Content" },
//   //
//   //         { "Table Name": "AUTHORITIES",
//   //         "Column Name": "nct_id",
//   //         "PRS Label": "Foreign key in AUTHORITIES linking to CLINICAL_STUDY",
//   //         "Data Type": 2,
//   //         "Max Length Used": 11,
//   //         "NLM Description": "NCT ID is a unique identification code given to each clinical study registered on ClinicalTrials.gov. The format is the letters 'NCT' followed by an 8-digit number (for example, NCT00000419).  [Ref: http://grants.nih.gov/clinicaltrials_fdaaa/definitions.htm?print=yes&]",
//   //         "NLM Required": false,
//   //         "FDAAA Required": false,
//   //         "Enumerations": "Sample Content" }
//   //     ];
//
//       var types = [
//           { Name: "", Id: 0 },
//           { Name: "Number", Id: 1 },
//           { Name: "VarChar2", Id: 2 },
//           { Name: "Clob", Id: 3 }
//       ];
//
//       $("#jsGrid").jsGrid({
//           width: "100%",
//           height: "auto",
//           data: clients,
//
//           inserting: false,
//           editing: false,
//           sorting: true,
//           paging: true,
//           autoload: false,
//           heading: true,
//           filtering: true,
//           selecting: true,
//           pageLoading: false,
//
//           fields: [
//               { name: "Name", type: "text", width: 150, validate: "required" },
//               { name: "Age", type: "number", width: 50 },
//               { name: "Address", type: "text", width: 200 },
//               { name: "Country", type: "select", items: types, valueField: "Id", textField: "Name" },
//               { name: "Married", type: "checkbox", title: "Is Married", sorting: false },
//               { type: "control" }
//           ],
//           //
//           // fields: [
//           //     { name: "Table Name", type: "text", width: 140 },
//           //     { name: "Column Name", type: "text", width: 140 },
//           //     { name: "PRS Label", type: "text"  },
//           //     { name: "Data Type", type: "select", items: types, valueField: "Id", textField: "Name" },
//           //     { name: "Max Length Used", type: "number", width: 60 },
//           //     { name: "NLM Description", type: "text", width: 300 },
//           //     { name: "NLM Req.", type: "checkbox", width: 60 },
//           //     { name: "FDAAA Req.", type: "checkbox", width: 60 },
//           //     { name: "Enumerations", type:"text" },
//           //     { name: "Comments", type: "text" },
//           //     { type: "control" }
//           // ],
//
//
//           noDataContent: "Not found",
//
//           pagerContainer: null,
//           pageIndex: 1,
//           pageSize: 20,
//           pageButtonCount: 15,
//           pagerFormat: "Pages: {first} {prev} {pages} {next} {last}    {pageIndex} of {pageCount}",
//           pagePrevText: "Prev",
//           pageNextText: "Next",
//           pageFirstText: "First",
//           pageLastText: "Last",
//           pageNavigatorNextText: "...",
//           pageNavigatorPrevText: "...",
//
//           invalidMessage: "Invalid data entered!",
//
//           loadIndication: true,
//           loadIndicationDelay: 500,
//           loadMessage: "Please, wait...",
//           loadShading: true,
//
//           updateOnResize: true
//     });
// });
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
// //
// // $(function() {
// //
// //     var types = [
// //       { Name: "", Id: 0 },
// //       { Name: "Number", Id: 1 },
// //       { Name: "VarChar2", Id: 2 },
// //       { Name: "Clob", Id: 3 }
// //     ];
// //
// //     var clients = [
// //       { "Table Name": "ARM_GROUPS",
// //       "Column Name": "arm_group_label",
// //       "PRS Label": "Arm or Group Label",
// //       "Data Type": 2,
// //       "Max Length Used": 62,
// //       "NLM Description": "Study Document Definitions:Arm Label - the short name used to identify the arm. (Limit: 62 characters).* (FDAAA)Examples: • Metformin • Lifestyle counseling • Sugar pill Group/Cohort Label - the short name used to identify the group. (Limit: 62 characters) * Examples: • Statin dose titration • Chronic kidney disease, no anemia • No treatment Results Document Definitions: Arm/Group * Definition: Arms or comparison groups in a trial Arm/Group Title * : Label used to identify the arm or comparison group. Minimum length is 4 characters. Titles shorter than the minimum are unlikely to sufficiently describe the arm or comparison group. Examples: fluoxetine; sertraline; drug-eluting stent; placebo (Limit: >=4 and <=62 characters) ",
// //       "NLM Required": true,
// //       "FDAAA Required": false,
// //       "Enumerations": "Sample Content" },
// //
// //       { "Table Name": "ARM_GROUPS",
// //       "Column Name": "arm_group_type",
// //       "PRS Label": "Arm Type",
// //       "Data Type": 2,
// //       "Max Length Used": 20,
// //       "NLM Description": "Study Document Definitions: Arm Type * (FDAAA)- select one Experimental Active Comparator Placebo Comparator Sham Comparator  No intervention Other",
// //       "NLM Required": true,
// //       "FDAAA Required": false,
// //       "Enumerations": "Sample Content" },
// //
// //       { "Table Name": "AUTHORITIES",
// //       "Column Name": "authority_id",
// //       "PRS Label": "Primary key for AUTHORITIES",
// //       "Data Type": 1,
// //       "Max Length Used": 6,
// //       "NLM Description": "",
// //       "NLM Required": false,
// //       "FDAAA Required": false,
// //       "Enumerations": "Sample Content" },
// //
// //       { "Table Name": "AUTHORITIES",
// //       "Column Name": "nct_id",
// //       "PRS Label": "Foreign key in AUTHORITIES linking to CLINICAL_STUDY",
// //       "Data Type": 2,
// //       "Max Length Used": 11,
// //       "NLM Description": "NCT ID is a unique identification code given to each clinical study registered on ClinicalTrials.gov. The format is the letters 'NCT' followed by an 8-digit number (for example, NCT00000419).  [Ref: http://grants.nih.gov/clinicaltrials_fdaaa/definitions.htm?print=yes&]",
// //       "NLM Required": false,
// //       "FDAAA Required": false,
// //       "Enumerations": "Sample Content" }
// //     ];
// //
// //     $("#jsGrid").jsGrid({
// //         height: "90%",
// //         width: "100%",
// //         data: clients,
// //
// //         filtering: true,
// //         editing: true,
// //         sorting: true,
// //         paging: true,
// //         autoload: true,
// //
// //         pageSize: 15,
// //         pageButtonCount: 5,
// //
// //         fields: [
// //             { name: "Table Name", type: "text", width: 140 },
// //             { name: "Column Name", type: "text", width: 140 },
// //             { name: "PRS Label", type: "text"  },
// //             { name: "Data Type", type: "select", items: types, valueField: "Id", textField: "Name" },
// //             { name: "Max Length Used", type: "number", width: 60 },
// //             { name: "NLM Description", type: "text", width: 300 },
// //             { name: "NLM Req.", type: "checkbox", width: 60 },
// //             { name: "FDAAA Req.", type: "checkbox", width: 60 },
// //             { name: "Enumerations", type:"text" },
// //             { name: "Comments", type: "text" },
// //             { type: "control" }
// //         ]
// //     });
// //
// // });
//
//
// //
// // $("#jsGrid").jsGrid({
// //     width: "100%",
// //     height: "400px",
// //
// //     filtering: true,
// //     editing: true,
// //     sorting: true,
// //     paging: true,
// //
// //     data: db.clients,
// //
// //     fields: [
// //         { name: "Name", type: "text", width: 150 },
// //         { name: "Age", type: "number", width: 50 },
// //         { name: "Address", type: "text", width: 200 },
// //         { name: "Country", type: "select", items: db.countries, valueField: "Id", textField: "Name" },
// //         { name: "Married", type: "checkbox", title: "Is Married", sorting: false },
// //         { type: "control" }
// //     ]
// // });


$(function() {
    $("#jsGrid").jsGrid({
        height: "80%",
        width: "100%",
        filtering: true,
        inserting: true,
        editing: true,
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
                    url: "/clients",
                    data: filter
                });
            }
        },
        fields: [
            { name: "name", type: "text", width: 150 },
            { name: "age", type: "number", width: 50, filtering: false },
            { name: "address", type: "text", width: 200 },
            { name: "married", type: "checkbox", title: "Is Married", filtering: false, sorting: false },
            { type: "control" }
        ]
    });
});
