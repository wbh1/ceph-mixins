{
  prometheusAlerts+:: {
    groups+: if $._config.isKubernetesCephDeployment then [
      {
        name: 'persistent-volume-alert.rules',
        rules: [
          {
            alert: 'PersistentVolumeUsageNearFull',
            expr: |||
              (kubelet_volume_stats_used_bytes * on (namespace,persistentvolumeclaim) group_left(storageclass, provisioner) (kube_persistentvolumeclaim_info * on (storageclass)  group_left(provisioner) kube_storageclass_info {provisioner=~"(.*rbd.csi.ceph.com)|(.*cephfs.csi.ceph.com)"})) / (kubelet_volume_stats_capacity_bytes * on (namespace,persistentvolumeclaim) group_left(storageclass, provisioner) (kube_persistentvolumeclaim_info * on (storageclass)  group_left(provisioner) kube_storageclass_info {provisioner=~"(.*rbd.csi.ceph.com)|(.*cephfs.csi.ceph.com)"})) > 0.75
            ||| % $._config,
            'for': $._config.pvcUtilizationAlertTime,
            labels: {
              severity: 'warning',
            },
            annotations: {
              summary: 'PVC {{ $labels.persistentvolumeclaim }} is nearing full. Data deletion or PVC expansion is required.',
              description: 'PVC {{ $labels.persistentvolumeclaim }} utilization has crossed 75%. Free up some space or expand the PVC.',
            },
          },
          {
            alert: 'PersistentVolumeUsageCritical',
            expr: |||
              (kubelet_volume_stats_used_bytes * on (namespace,persistentvolumeclaim) group_left(storageclass, provisioner) (kube_persistentvolumeclaim_info * on (storageclass)  group_left(provisioner) kube_storageclass_info {provisioner=~"(.*rbd.csi.ceph.com)|(.*cephfs.csi.ceph.com)"})) / (kubelet_volume_stats_capacity_bytes * on (namespace,persistentvolumeclaim) group_left(storageclass, provisioner) (kube_persistentvolumeclaim_info * on (storageclass)  group_left(provisioner) kube_storageclass_info {provisioner=~"(.*rbd.csi.ceph.com)|(.*cephfs.csi.ceph.com)"})) > 0.85
            ||| % $._config,
            'for': $._config.pvcUtilizationAlertTime,
            labels: {
              severity: 'critical',
            },
            annotations: {
              summary: 'PVC {{ $labels.persistentvolumeclaim }} is critically full. Data deletion or PVC expansion is required.',
              description: 'PVC {{ $labels.persistentvolumeclaim }} utilization has crossed 85%. Free up some space or expand the PVC immediately.',
            },
          },
        ],
      },
    ] else [],
  },
}
