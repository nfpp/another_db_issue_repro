CREATE TABLE IF NOT EXISTS default.foo (
    `server_date` Date,
    `something` String
)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/default/{shard}/foo', '{replica}')
PARTITION BY toYYYYMM(server_date)
ORDER BY (server_date, something)
SETTINGS index_granularity = 8192;

CREATE TABLE IF NOT EXISTS test.foo (
    `server_date` Date,
    `something` String
)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/testt/{shard}/foo', '{replica}')
PARTITION BY toYYYYMM(server_date)
ORDER BY (server_date, something)
SETTINGS index_granularity = 8192;

CREATE TABLE IF NOT EXISTS default.bar_shard (
    `server_date` Date,
    `something_else` String
)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/default/{shard}/bar', '{replica}')
ORDER BY (server_date, something_else)
SETTINGS index_granularity = 8192;


CREATE TABLE IF NOT EXISTS test.bar_shard (
    `server_date` Date,
    `something_else` String
)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/test/{shard}/bar', '{replica}')
ORDER BY (server_date, something_else)
SETTINGS index_granularity = 8192;


CREATE TABLE IF NOT EXISTS default.bar (
    `server_date` Date,
    `something_else` String
)
ENGINE = Distributed(analytics, default, bar_shard, rand());

CREATE TABLE IF NOT EXISTS test.bar (
    `server_date` Date,
    `something_else` String
)
ENGINE = Distributed(analytics, test, bar_shard, rand());
