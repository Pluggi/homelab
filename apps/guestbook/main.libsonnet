local lib = import "../libs/main.libsonnet";


local ctx = {
  team: "eng-guestbook",
  budget: "engineering",
  svc: "guestbook",
  kube_cluster: "k3d-homelab",
};

local redis = import "./redis.libsonnet";

local app = lib.argocd.app.new(ctx, "guestbook", "guestbook");

lib.utils.exportKubernetesManifests(
  [
    app,
  ]
  + redis
)
