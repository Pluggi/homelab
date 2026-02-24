local labelsLib = import "./labels.libsonnet";
local k = import "github.com/jsonnet-libs/k8s-libsonnet/1.34/main.libsonnet";

{
  new(ctx, name, namespace, containers):
    k.apps.v1.deployment.new(
      name=name,
      containers=containers,
    )
    + k.apps.v1.deployment.metadata.withNamespace(namespace)
    + k.apps.v1.deployment.mixin.spec.selector.withMatchLabels({ app: name })
    + k.apps.v1.deployment.mixin.spec.template.metadata.withLabels({ app: name })
    + labelsLib.withCommonLabels(ctx),
}
