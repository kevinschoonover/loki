{
  local makePrefix(groups) = std.join('_', groups),
  local makeGroupBy(groups) = std.join(', ', groups),

  local group_by_cluster = makeGroupBy($._config.cluster_labels),

  _config+:: {
    // Tags for dashboards.
    tags: ['loki'],

    singleBinary: false,

    // The label used to differentiate between different application instances (i.e. 'pod' in a kubernetes install).
    per_instance_label: 'pod',

    // The label used to differentiate between different nodes (i.e. servers).
    per_node_label: 'instance',

    // These are used by the dashboards and allow for the simultaneous display of
    // microservice and single binary loki clusters.
    job_names: {
      gateway: '(gateway|loki-gw|loki-gw-internal)',
      query_frontend: '(query-frontend.*|loki$)',  // Match also custom query-frontend deployments.
      querier: '(querier.*|loki$)',  // Match also custom querier deployments.
      ingester: '(ingester.*|loki$)',  // Match also custom and per-zone ingester deployments.
      distributor: '(distributor.*|loki$)',
      index_gateway: '(index-gateway.*|querier.*|loki$)',
      ruler: '(ruler|loki$)',
      compactor: 'compactor.*',  // Match also custom compactor deployments.
    },

    // Grouping labels, to uniquely identify and group by {jobs, clusters}
    job_labels: ['datacenter', 'namespace', 'service'],
    cluster_labels: ['datacenter', 'namespace'],

    _group: {
      // Each group prefix is composed of `_`-separated labels
      group_prefix_jobs: makePrefix($._config.job_labels),
      group_prefix_clusters: makePrefix($._config.cluster_labels),

      // Each group-by label list is `, `-separated and unique identifies
      group_by_job: makeGroupBy($._config.job_labels),
      group_by_cluster: makeGroupBy($._config.cluster_labels),
    },
  },
}
