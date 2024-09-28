# Solution

## Prerequisities

- `node` and `npm` installed.
- `npm install -D typescript ts-node @types/node`

## Extract chain data

```
START=2125000 COUNT=189500 make run
```

## Prepare DB and load raw data

- Prepare DBs for the raw data tables and metrics views: [./sql/0001_init_tables.sql](./sql/0001_init_tables.sql).
- Load blocks: [./sql/0002_load_blocks.sql](./sql/0002_load_blocks.sql).
- Load transactions:[./sql/0003_load_transactions.sql](./sql/0003_load_transactions.sql).
- Load receipts: [./sql/0004_load_receipts.sql](./sql/0004_load_receipts.sql).

## Querying and cleanup

- Relevant queries for the raw data and metrics can be found at [./sql/queries.sql](./sql/queries.sql).
- Cleanup queries can be found at [./sql/cleanup.sql](./sql/cleanup.sql).

## Assumptions

- The focus on this task was more on the functionality of the individual components as per the task instruction steps i.e.
    - Extract chain data.
    - Prepare DB.
    - Load data.

    The current pipeline components are not built for scheduled running i.e. as it is now, it won't be able to be handle updates safely.
- The trending contract metrics were created using views instead of dedicated tables for the interest of time.

## Further improvements

- Add more functionality to the indexer:
    - Better error handling and improved logging.
    - Checkpoint system to allow resuming from where it was left off.
    - Parallelization for improved performance.
    - Database integration.
    - Command line arguments.
-  Use Clickhouse's [materialized views](https://clickhouse.com/docs/en/materialized-view) for the metrics dashboards to avoid querying the raw data repeatedly.