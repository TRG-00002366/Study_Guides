# Scripts Folder

This folder contains Python scripts used by the StreamFlow pipeline DAG.

## Scripts

- `kafka_batch_consumer.py` - Batch consumes from Kafka topics, writes JSON files
- `kafka_data_producer.py` - Generates sample events for demo

## Usage

These scripts are called by the `streamflow_pipeline_dag.py` DAG.
For manual testing, see the commands in the demo INSTRUCTOR_GUIDE.md.
