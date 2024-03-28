# Mapping Documentation

## Introduction
We created a way to describe how to map a JSON document from clinicaltrials.gov. The worker loads n json documents and run each mapping at a time. Think of each mapping entry as describing how to do a mass load into the specified table. The mapping entries can repeat tables, this is useful when we are sending data from different parts of the document to the same table, for example browse_conditions. Once the mapping is defined, the worker can work on importing thousands of studies at once. The only reason to split the import process into batches is because we do not infinite amount of memory.

Each mapping entry describes the table that will be populated by data

```ruby
{
  table: :brief_descriptions,
  root: [:protocolSection, :descriptionModule],
  columns: [
    { name: :description, value: :briefSummary }
  ]
}
```

- `table:` defines what table we want to insert the data into
- `root:` restricts the searches to document, this makes all other path definitions relative to this, making description briefer. When the root is a hash we assume that we will be inserting one row into the table. When root is an array, we assume that we have to insert one row per element in the table. 
- `columns:` describes how to populate the columns for each row of the table we are going to try to insert
  - `name:` the column name to add the data to
  - `value:` describes where to find the value for the column, this can be an array, symbol, string, integer or optional
    - array: defines a path to navigate the object in order to arrive at the value
    - symbol: for when the path is only one level deep, instead of writing `[:foo]` we can write `:foo`
    - string: static value, it always sets the same value
    - when not specied the whole object is the value
  - `convert_to:` describes what method we want to use to convert the value before the save it to the database
    - Symbol: one of the predefined convert functions is used
      - date: converts a string into a Date type
      - downcase: downcases the string
    - Proc: uses the proc to convert the value