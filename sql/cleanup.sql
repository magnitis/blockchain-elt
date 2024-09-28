DROP TABLE IF EXISTS raw.blocks;
DROP TABLE IF EXISTS raw.transactions;
DROP TABLE IF EXISTS raw.receipts;
DROP TABLE IF EXISTS raw.traces;
DROP DATABASE IF EXISTS raw;

DROP VIEW IF EXISTS metrics.gas_used_daily;
DROP VIEW IF EXISTS metrics.active_addresses_daily;
DROP VIEW IF EXISTS metrics.transactions_count_daily;
DROP DATABASE IF EXISTS metrics;
