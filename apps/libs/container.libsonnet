local k = import "github.com/jsonnet-libs/k8s-libsonnet/1.34/main.libsonnet";

{
  new(name, image, ports=[]):
    k.core.v1.container.new(
      name=name,
      image=image
    )
    + k.core.v1.container.withPorts(ports),

  withCommonEnv(ctx): (
    local downardEnv = {
      NODE_NAME: "spec.nodeName",
      POD_IP: "status.podIP",
    };

    local staticEnv = {
      KUBE_CLUSTER: ctx.kube_cluster,
    };

    k.core.v1.container.withEnvMixin([
      {
        name: key,
        valueFrom: {
          fieldRef: {
            fieldPath: downardEnv[key],
          },
        },
      }
      for key in std.objectFields(downardEnv)
    ])
    + k.core.v1.container.withEnvMixin([
      {
        name: key,
        value: staticEnv[key],
      }
      for key in std.objectFields(staticEnv)
    ])
  ),
}
