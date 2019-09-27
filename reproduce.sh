#!/bin/bash
set -e

trap clean EXIT

clean() {
    docker-compose -p repro down
}

docker-compose -p repro up -d

for i in {1..4}; do
    docker exec -t "repro_clickhouse-cluster-${i}_1" clickhouse-client -q "$(cat create_table.sql)"
done
sleep 1

for i in {1..4..2}; do
    docker exec -t "repro_clickhouse-cluster-${i}_1" clickhouse-client -q "$(cat fill_data.sql)" --insert_quorum 2
done
sleep 5

docker exec -t "repro_clickhouse-cluster-1_1" clickhouse-client -q "ALTER TABLE foo DELETE WHERE something = 'test1';"

while true; do
    COUNT=$(docker exec -t "repro_clickhouse-cluster-1_1" clickhouse-client -q "SELECT count() FROM system.mutations WHERE is_done = 0;")
    if [[ $(echo -e "${COUNT}" | tr -d '[:space:]') != "0" ]]; then
        echo "waiting for the mutation to finish"
        sleep 1
    else
        break
    fi
done
