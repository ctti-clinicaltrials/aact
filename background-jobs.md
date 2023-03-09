# Background Jobs

## Rake Task

```
  loop {
    sleep 10
    job = BackgroundJob.where(status: 'pending').order(created_at: :asc).first
    job.process if job
  }
```

## BackgroundJob::Query

Write a class that extends from BackgroundJob that can process a query and perform the following below. This would live inside the `process` method in the class `BackgroundJob::Query`

1. Mark the job as 'working'
2. Running the query as a read only user

If Running the query was successful
   1. Create a csv file from the query results
   2. Upload the csv to the cloud
   3. Add metadata information to the BackgroundJob (the number of rows from the query) I think we need to add a column type json to store that
   4. Mark the job as 'complete' and set the completed time as now

If Running the query is unsuccessful
  1. Add information about the error that happened to the metadata column
  2. Mark the job as 'error'