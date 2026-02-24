local k = import "github.com/jsonnet-libs/k8s-libsonnet/1.34/main.libsonnet";

{
  new(name, namespace, selector, ports, type="ClusterIP"):
    k.core.v1.service.new(
      name=name,
      selector=selector,
      ports=ports,
    )
    + k.core.v1.service.metadata.withNamespace(namespace)
    + k.core.v1.service.spec.withType(type)
  ,

  fromDeployment(name, namespace, deployment, ports=[], type="ClusterIP"):
    assert deployment.kind == "Deployment" : "Only works with deployments";

    local selector = deployment.spec.template.metadata.labels;

    local svcPortFromCtrPort(init, port) =
      local portName = std.get(port, "name");
      init + [{
        [if portName != null then "name"]: portName,
        protocol: "TCP",
        port: port.containerPort,
        targetPort: port.containerPort,
      }];

    local svcPortsFromContainer(init, container) =
      std.foldl(
        function(acc, port) svcPortFromCtrPort(acc, port),
        container.ports,
        init,
      );

    local discoveredPorts =
      std.foldl(
        svcPortsFromContainer,
        deployment.spec.template.spec.containers,
        [],
      );

    local effectivePorts = if ports != [] then ports else discoveredPorts;

    self.new(name, namespace, selector, effectivePorts, type),
}
