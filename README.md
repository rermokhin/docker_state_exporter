# Docker State Exporter

Exporter for docker container state

Prometheus exporter for docker container state, written in Go.

One of the best known exporters of docker container information is [cAdvisor](https://github.com/google/cadvisor).\
However, cAdvisor does not export the state of the container.

This exporter will only export the container status and the restarts count.

## Installation and Usage

The `docker_state_exporter` listens on HTTP port 8080 by default.

### Docker

For Docker run.

```bash
sudo docker run -d \
  -v "/var/run/docker.sock:/var/run/docker.sock" \
  -p 8080:8080 \
  rermokhin/docker_state_exporter \
  -listen-address=:8080
```

For Docker compose.

```yaml
---
version: '3.8'

services:
  docker_state_exporter:
    image: rermokhin/docker_state_exporter
    volumes:
      - type: bind
        source: /var/run/docker.sock
        target: /var/run/docker.sock
    ports:
      - "8080:8080"
```

## Metrics

This exporter will export the following metrics.

- container_state_health_status
- container_state_status
- container_state_oomkilled
- container_state_startedat
- container_state_finishedat
- container_restartcount

These metrics will be the same as the results of docker inspect.

container_state_health_status:
| Status | Code |
| --- | ------ |
| unhealthy | 0 |
| none | 1 |
| starting | 2 |
| healthy | 3 |

container_state_status:
| Status | Code |
| --- | ------ |
| removing | 0 |
| dead | 1 |
| exited | 2 |
| paused | 3 |
| restarting | 4 |
| created | 5 |
| running | 6 |

This exporter also exports the standard
[Go Collector](https://pkg.go.dev/github.com/prometheus/client_golang/prometheus#NewGoCollector)
and [Process Collector](https://pkg.go.dev/github.com/prometheus/client_golang/prometheus#NewProcessCollector).

## Caution

This exporter will do a docker inspect every time prometheus pulls.\
If a large number of requests are made, there will be performance issues. (I think. Not verified.)\
So, this app caches the result of docker inspect for 1 second.
So, please note that if you set the scrape_interval of prometheus to less than one second, you may get the same result back.

## Development building and running

I am running this application on Docker (linux/amd64).
I have not tested it in any other environment.

### Build

```bash
git clone https://github.com/rermokhin/docker_state_exporter
cd docker_state_exporter
sudo docker build -t docker_state_exporter_test .
```

### Run

```bash
sudo docker run -d \
  -v "/var/run/docker.sock:/var/run/docker.sock" \
  -p 8080:8080 \
  docker_state_exporter_test \
  -listen-address=:8080 \
  -add-container-labels=false \
  -cache-period=2
```
