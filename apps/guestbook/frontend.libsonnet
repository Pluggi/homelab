local lib = import "../libs/main.libsonnet";
local k = import "github.com/jsonnet-libs/k8s-libsonnet/1.34/main.libsonnet";

local ctx = {
  team: "eng-guestbook",
  budget: "engineering",
  svc: "guestbook",
  kube_cluster: "k3d-homelab",
};

local appName = "frontend";
local namespace = "guestbook";
local image = "us-docker.pkg.dev/google-samples/containers/gke/gb-frontend:v5";
local port = 80;

local workloads(ctx, name, namespace, image) = (
  local container = lib.container.new(
                      name, image, ports=[
                        {
                          name: "http",
                          containerPort: 80,
                        },
                      ]
                    )
                    + lib.container.withCommonEnv(ctx);
  local deployment = lib.deployment.new(ctx, name, namespace, [container]);

  local svc = lib.service.fromDeployment(ctx, name, namespace, deployment);

  [
    deployment,
    svc,
  ]
);

workloads(ctx, appName, namespace, image)
