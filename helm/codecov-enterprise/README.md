# Codecov Enterprise Helm Chart

This helm chart can be used to deploy the Codecov Enterprise application to 
a Kubernetes cluster.  It assumes you will provide external dependencies,
including a PostgreSQL and Redis database, and an S3-compatible object store
such as Minio.

## Prerequisites

- A working [kubernetes cluster](https://kubernetes.io/docs/home/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) configured
  to access your cluster.

## Required services

- A PostgreSQL v10 server configured to allow connections from your k8s cluster. 
- A Redis server configured to allow connections from your k8s cluster.
- An S3-compatible object store such as [minio](https://min.io/download).
- A load balancer or other form of ingress into your k8s cluster.

## Parameters

| name | description | default |
| --- | --- | --- |
| `codecovYml` | Path to your enterprise [codecov.yml](https://docs.codecov.io/docs/configuration). [example](codecov.yml.example) | required |
| `scmCaCert` | Path to optional SCM CA certificate in PEM format | |

Additional configuration including the number of web and worker replicas and
their CPU and memory limits can be tuned by overriding `values.yaml`.  See
[codecov-enterprise/values.yaml](codecov-enterprise/values.yaml) for the
available variables.

## Installation

```
helm install \
	--generate-name \
	--set-file codecovYaml=./codecov.yml \
	--values values.yaml 
	./codecov-enterprise/
```
