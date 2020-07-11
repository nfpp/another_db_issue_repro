#!/bin/bash
set -e

trap clean EXIT

clean() {
    docker-compose -p repro down
}

docker-compose -p repro up -d
sleep 1

docker exec -t "repro_clickhouse-cluster-1_1" clickhouse-client -q "CREATE DATABASE IF NOT EXISTS test ON CLUSTER analytics;"

for i in {1..4}; do
    docker exec -t "repro_clickhouse-cluster-${i}_1" clickhouse-client -n -q "$(cat create_table.sql)"
done
sleep 1

for i in {1..4..2}; do
    docker exec -t "repro_clickhouse-cluster-${i}_1" clickhouse-client -q "$(cat fill_data_foo_default.sql)"
    docker exec -t "repro_clickhouse-cluster-${i}_1" clickhouse-client -q "$(cat fill_data_foo_test.sql)"
done
docker exec -t "repro_clickhouse-cluster-${i}_1" clickhouse-client -q "$(cat fill_data_bar_default.sql)"
docker exec -t "repro_clickhouse-cluster-${i}_1" clickhouse-client -q "$(cat fill_data_bar_test.sql)"
sleep 4

echo "default (from foo):"
docker exec -t "repro_clickhouse-cluster-1_1" clickhouse-client -q "SELECT count(something_else) FROM bar WHERE something_else IN (SELECT something FROM foo);"
echo "test (from foo):"
docker exec -t "repro_clickhouse-cluster-1_1" clickhouse-client --database test -q "SELECT count(something_else) FROM bar WHERE something_else IN (SELECT something FROM foo);"
echo "test (from test.foo):"
docker exec -t "repro_clickhouse-cluster-1_1" clickhouse-client --database test -q "SELECT count(something_else) FROM bar WHERE something_else IN (SELECT something FROM test.foo);"
