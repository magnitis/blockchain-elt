-- Raw chain data
select * from raw.blocks order by timestamp desc limit 5;

select * from raw.transactions order by blockTimestamp desc limit 5;

select * from raw.receipts order by blockTimestamp desc limit 5;

-- Metrics
select * from metrics.gas_used_daily order by gas_used desc limit 5;

select * from metrics.active_addresses_daily order by active_addresses_count desc limit 5;

select * from metrics.transactions_count_daily order by transactions_count desc limit 5;
