-- Raw chain data
CREATE DATABASE IF NOT EXISTS raw;

-- Blocks
CREATE TABLE IF NOT EXISTS raw.blocks
(
	`timestamp` DateTime,
	`number` Int64,
	`baseFeePerGas` Nullable(Int256),
	`difficulty` Nullable(Int256),
	`extraData` Nullable(String),
	`gasLimit` Nullable(Int256),
	`gasUsed` Nullable(Int256),
	`hash` String,
	`logsBloom` Nullable(String),
	`miner` Nullable(String),
	`mixHash` Nullable(String),
	`nonce` Nullable(String),
	`parentHash` Nullable(String),
	`receiptsRoot` Nullable(String),
	`sha3Uncles` Nullable(String),
	`size` Nullable(Int256),
	`stateRoot` Nullable(String),
	`totalDifficulty` Nullable(Int256),
	`transactionsRoot` Nullable(String),
	`uncles` Array(Nullable(String))
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(timestamp)
ORDER BY timestamp;

-- Transactions
CREATE TABLE IF NOT EXISTS raw.transactions
(
  `blockTimestamp` DateTime,
  `blockHash` Nullable(String),
  `blockNumber` Int64,
  `from` String,
  `gas` Int256,
  `gasPrice` Int256,
  `hash` String,
  `input` String,
  `nonce` String,
  `to` String,
  `transactionIndex` Int64,
  `value` Nullable(String),
  `type` Nullable(String),
  `chainId` Nullable(String),
  `v` Nullable(String),
  `r` Nullable(String),
  `s` Nullable(String),
  `maxFeePerGas` Int256,
  `maxPriorityFeePerGas` Nullable(Int256),
  `accessList` Array(Nullable(String)),
  `yParity` Nullable(String)
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(blockTimestamp)
ORDER BY blockTimestamp;

-- Receipts
CREATE TABLE IF NOT EXISTS raw.receipts
(
  `blockNumber` Int64,
  `blockTimestamp` DateTime,
  `blockHash` String,
  `contractAddress` String,
  `cumulativeGasUsed` Int256,
  `effectiveGasPrice` Int256,
  `from` String,
  `gasUsed` Int256,
  `logs` Array(Tuple(    address String,    blockHash String,   blockNumber Int64,   data String,   logIndex String,    removed Bool,   topics Array(String),   transactionHash String,    transactionIndex String)),
  `logsBloom` String,
  `status` String,
  `to` String,
  `transactionHash` String,
  `transactionIndex` Int64,
  `type` String,
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(blockTimestamp)
ORDER BY blockTimestamp;


-- Analytics
CREATE DATABASE IF NOT EXISTS metrics;

-- Daily gas used
CREATE VIEW IF NOT EXISTS metrics.gas_used_daily AS
WITH daily_gas_usage AS (
    SELECT
        toDate(transactions.blockTimestamp) AS date,
        transactions.to AS contract_address,
        sum(receipts.gasUsed) AS total_gas_used
    FROM raw.transactions AS transactions
    JOIN raw.receipts AS receipts ON transactions.hash = receipts.transactionHash
    WHERE transactions.to IS NOT NULL
    GROUP BY 
        toDate(transactions.blockTimestamp),
        transactions.to
)
SELECT
    date AS timestamp,
    contract_address,
    total_gas_used AS gas_used
FROM daily_gas_usage
ORDER BY 
    timestamp,
    contract_address;

-- Daily active addresses
CREATE VIEW IF NOT EXISTS metrics.active_addresses_daily AS
WITH daily_active_addresses AS (
    SELECT
        toDate(transactions.blockTimestamp) AS date,
        transactions.to AS contract_address,
        count(DISTINCT transactions.from) AS unique_addresses
    FROM raw.transactions AS transactions
    WHERE transactions.to IS NOT NULL
    GROUP BY 
        toDate(transactions.blockTimestamp),
        transactions.to
)
SELECT
    date AS timestamp,
    contract_address,
    unique_addresses AS active_addresses_count
FROM daily_active_addresses
ORDER BY 
    timestamp,
    contract_address;

-- Daily transactions count
CREATE VIEW IF NOT EXISTS metrics.transactions_count_daily AS
WITH daily_transaction_counts AS (
    SELECT
        toDate(transactions.blockTimestamp) AS date,
        transactions.to AS contract_address,
        count(*) AS total_transactions
    FROM raw.transactions AS transactions
    WHERE transactions.to IS NOT NULL
    GROUP BY 
        toDate(transactions.blockTimestamp),
        transactions.to
)
SELECT
    date AS timestamp,
    contract_address,
    total_transactions AS transactions_count
FROM daily_transaction_counts
ORDER BY 
    timestamp,
    contract_address;

