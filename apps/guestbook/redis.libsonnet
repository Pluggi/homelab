local lib = import "../libs/main.libsonnet";
local k = import "github.com/jsonnet-libs/k8s-libsonnet/1.34/main.libsonnet";

local ctx = {
  team: "eng-guestbook",
  budget: "engineering",
  svc: "guestbook",
  kube_cluster: "k3d-homelab",
};

local appName = "redis";
local namespace = "guestbook";
local image = "registry.k8s.io/redis@sha256:cb111d1bd870a6a471385a4a69ad17469d326e9dd91e0e455350cacf36e1b3ee";
local port = 6379;

local workloads(ctx, name, namespace, image) = (
  local container = lib.container.new(
                      name, image, ports=[
                        {
                          name: "redis",
                          containerPort: port,
                        },
                      ]
                    )
                    + lib.container.withCommonEnv(ctx);
  local leaderDeployment = lib.deployment.new(ctx, name, namespace, [container]);
  local leaderSvc = lib.service.fromDeployment(ctx, name, namespace, leaderDeployment);

  local followerDeployment = lib.deployment.new(ctx, name + "-follower", namespace, [container]);
  local followerSvc = lib.service.fromDeployment(ctx, name + "-follower", namespace, leaderDeployment);

  [
    leaderDeployment,
    leaderSvc,
    followerDeployment,
    followerSvc,
  ]
);

workloads(ctx, appName, namespace, image)
+ [
  lib.argocd.app.new(ctx, appName, namespace),
]
