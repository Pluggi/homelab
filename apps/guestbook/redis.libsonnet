local lib = import "../libs/main.libsonnet";
local k = import "github.com/jsonnet-libs/k8s-libsonnet/1.34/main.libsonnet";

local ctx = {
  team: "eng-guestbook",
  budget: "engineering",
  svc: "guestbook",
  kube_cluster: "k3d-homelab",
};

local appName = "guestbook";
local namespace = "guestbook";
local image = "nginx:1.25";
local port = 80;

local redis(ctx, name, namespace) = (
  local redisImage = "registry.k8s.io/redis@sha256:cb111d1bd870a6a471385a4a69ad17469d326e9dd91e0e455350cacf36e1b3ee";
  local container = lib.container.new("redis", redisImage, ports=[
    {
      name: "redis",
      containerPort: 6379,
    },
  ]);
  local deployment = lib.deployment.new(ctx, name, namespace, [container]);

  local svc = lib.service.fromDeployment(ctx, name, namespace, deployment);

  [
    deployment,
    svc,
  ]
);

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

lib.utils.exportKubernetesManifests(
  redis(ctx, "redis", namespace)
  + [
    lib.argocd.app.new(ctx, "guestbook", "guestbook"),
    // deployment,
    // svc,
  ]
)
