CREATE TABLE IF NOT EXISTS default.foo (
    `server_date` Date,
    `something` String
)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/default/{shard}/foo', '{replica}')
PARTITION BY toYYYYMM(server_date)
ORDER BY (server_date, something)
SETTINGS index_granularity = 8192;
