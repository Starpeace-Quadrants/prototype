#!/bin/bash
set -e

echo "Creating Kafka topics..."

KAFKA_BROKER="kafka:9092"

while IFS=: read -r topic partitions replication; do
  if [[ -z "$topic" || -z "$partitions" || -z "$replication" ]]; then
    echo "Skipping malformed line: $topic:$partitions:$replication"
    continue
  fi

  echo "Creating topic: $topic with $partitions partitions and RF=$replication"

  kafka-topics.sh \
    --bootstrap-server "$KAFKA_BROKER" \
    --create \
    --if-not-exists \
    --topic "$topic" \
    --partitions "$partitions" \
    --replication-factor "$replication"
done < /topics.txt

echo "Kafka topics created."
