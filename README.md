# Prerequisites

The following X.509 certificates and private keys are required to be in `certificates` directory.
These are used for Elasticsearch and Kibana data-in-transit security and mutual authentication.

All the certificates need to be valid.

### Root CA certificate
* sccoe_root_ca.cert

### Leaf certificates
Elasticsearch interface on port 9200:
* sccoe-sys-elastic-elasticsearch-server-internal.pem
* sccoe-sys-elastic-elasticsearch-server-internal.key

Kibana interface on port 5601:
* sccoe-sys-elastic-kibana-server-management.pem
* sccoe-sys-elastic-kibana-server-management.key

Kibana system authentication to Elasticsearch:
* sccoe-sys-elastic-kibana-client-internal.pem
* sccoe-sys-elastic-kibana-client-internal.key

The leaf certificates shall be signed by the root CA.

The actual subjects of the certificates do not really matter much as long
as the leaf certificates are issued by the root CA. The subject of
`sccoe-sys-elastic-kibana-client-internal.pem` is used in `setup-elasticsearch.sh`
for setting up the role mapping for `kibana_system`.

# Deployment

1. Start elasticsearch and wait until it starts:
```shell
docker compose up -d elasticsearch
```

2. Run `setup-elasticsearch.sh` script. Wait until it finishes.

3. Start `package-registry` container. Wait until it completely initializes:
```shell
docker compose up -d package-registry
```

4. Start `kibana` container. Wait until it completely initializes:
```shell
docker compose up kibana
```

# Verification
1. Navigate to `Stack Management` > `Index Management` > `Component Templates`.
2. Find component template `metrics-prometheus.collector@package`.
3. Review the contents of the component template, for example in `Edit` > `Review` > `Request`.
4. Observe that the following dynamic template is present:
```json
        {
          "prometheus.*": {
            "path_match": "prometheus.*",
            "mapping": {
              "dynamic": true,
              "type": "object"
            },
            "match_mapping_type": "object"
          }
        }
```
