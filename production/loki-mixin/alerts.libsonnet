{
  prometheusAlerts+:: {
    groups+: [
      {
        name: 'loki_alerts',
        rules: [
          {
            alert: 'LokiRequestErrors',
            expr: |||
              100 * sum(rate(loki_request_duration_seconds_count{status_code=~"5.."}[1m])) by (%s, route)
                /
              sum(rate(loki_request_duration_seconds_count[1m])) by (%s, route)
                > 10
            ||| % [$._config._group.group_by_job, $._config._group.group_by_job],
            'for': '15m',
            labels: {
              severity: 'critical',
            },
            annotations: {
              message: |||
                %s is experiencing {{ printf "%%.2f" $value }}%% errors.
              ||| % $._config._group.group_instance_alert_labels,
            },
          },
          {
            alert: 'LokiRequestPanics',
            expr: |||
              sum(increase(loki_panic_total[10m])) by (%s) > 0
            ||| % $._config._group.group_by_job,
            labels: {
              severity: 'critical',
            },
            annotations: {
              message: |||
                %s is experiencing {{ printf "%%.2f" $value }}%% increase of panics.
              ||| % $._config._group.group_instance_alert_labels,
            },
          },
          {
            alert: 'LokiRequestLatency',
            expr: |||
              %s_route:loki_request_duration_seconds:99quantile{route!~"(?i).*tail.*"} > 1
            ||| % $._config._group.group_prefix_jobs,
            'for': '15m',
            labels: {
              severity: 'critical',
            },
            annotations: {
              message: |||
                %s is experiencing {{ printf "%%.2f" $value }}s 99th percentile latency.
              ||| % $._config._group.group_instance_alert_labels,
            },
          },
          {
            alert: 'LokiTooManyCompactorsRunning',
            expr: |||
              sum(loki_boltdb_shipper_compactor_running) by (%s) > 1
            ||| % $._config.per_namespace_label,
            'for': '5m',
            labels: {
              severity: 'warning',
            },
            annotations: {
              message: |||
                {{ $labels.%s }} has had {{ printf "%%.0f" $value }} compactors running for more than 5m. Only one compactor should run at a time.
              ||| % $._config.per_namespace_label,
            },
          },
        ],
      },
    ],
  },
}
