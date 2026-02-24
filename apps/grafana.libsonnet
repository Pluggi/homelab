local lib = import "./libs/main.libsonnet";
local k = import "github.com/jsonnet-libs/k8s-libsonnet/1.34/main.libsonnet";

local ctx = {
  team: "sre",
  budget: "engineering",
  svc: "grafana",
  kube_cluster: "k3d-homelab",
};

local appName = "demo-app";
local namespace = "default";
local image = "nginx:1.25";
local port = 80;

local containers = [
  lib.container.new(appName, image, ports=[
    {
      name: "http",
      containerPort: port,
    },
  ])
  + lib.container.withCommonEnv(ctx),
];
local deployment = lib.deployment.new(ctx, appName, namespace, containers);
local svc = lib.service.fromDeployment(
  ctx,
  name=appName,
  namespace=namespace,
  deployment=deployment,
);

lib.utils.exportKubernetesManifests([
  lib.argocd.app.new(ctx, "grafana", "grafana"),
  deployment,
  svc,
])
