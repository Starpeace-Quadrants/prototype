#!/usr/bin/env bash

echo "Beginning creation of default topics."

topics="./topics.txt"
while IFS= read -r line
do
  IFS=":" read -ra params <<< "$line"
  /opt/bitnami/kafka/bin/kafka-topics.sh --bootstrap-server kafka:9092 --create --if-not-exists --topic "${params[0]}" --replication-factor "${params[1]}" --partitions "${params[2]}"
done < "$topics"

echo -e 'Successfully created the following topics:'
/opt/bitnami/kafka/bin/kafka-topics.sh --list --bootstrap-server kafka:9092