# Homelab ClickHouse

A ClickHouse cluster running on k3d for development and experimentation. Targets macOS (nix-darwin) with direnv.

## Topology

- **ClickHouseKeeper** — 1 StatefulSet, 3 replicas, Raft quorum for coordination
- **ClickHouse** — 1 StatefulSet per shard, 2 shards, 2 replicas each
- **Storage policy** — `tiered` (hot/cold disks on the data PVC)

## Prerequisites

- macOS with [nix-darwin](https://github.com/LnL7/nix-darwin) and [direnv](https://direnv.net/) installed
- Docker Desktop running (required by k3d)

direnv activates the Nix dev shell automatically on `cd`. Allow it the first time:

```sh
direnv allow
```

## Usage

```sh
task setup        # create k3d cluster, install Keeper, ClickHouse, and monitoring
task teardown     # destroy the cluster
```

See `task --list` for all available tasks.

## Connections

| Service | URL | Notes |
|---------|-----|-------|
| Grafana | http://grafana.localhost:8080 | admin / grafana |
| Prometheus | http://prometheus.localhost:8080 | |
| ClickHouse HTTP | `task ch:forward` then http://localhost:8123 | for curl / HTTP queries |
| ClickHouse native | `task ch:forward` then localhost:9000 | for clickhouse-client |

## Monitoring

Prometheus scrapes ClickHouse metrics (port 9363) and Kubernetes node/pod metrics via kube-state-metrics and node-exporter. Grafana is pre-configured with Prometheus as a datasource.

For querying ClickHouse data directly in Grafana, install the [ClickHouse datasource plugin](https://grafana.com/grafana/plugins/grafana-clickhouse-datasource) and connect to:

- Host: `clickhouse-shard1.clickhouse.svc.cluster.local`
- Port: `9000` (native) or `8123` (HTTP)
- Username: `default`

## Loading data

Place data files in `./data/`. The directory is mounted into all agent nodes and exposed inside ClickHouse pods at `/var/lib/clickhouse/user_files`, so files are accessible via the `file()` table function:

Insert into the Distributed table from a single node (via `ch:forward`) to shard data correctly:
