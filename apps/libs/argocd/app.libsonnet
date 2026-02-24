{
  new(ctx, name, namespace, project="default"): (
    {
      apiVersion: "argoproj.io/v1alpha1",
      kind: "Application",
      metadata: {
        name: name,
        namespace: "argocd",
      },
      spec: {
        project: "default",
        source: {
          repoURL: "https://github.com/Pluggi/homelab.git",
          targetRevision: "main",
          path: "apps/generated/%s" % name,
          directory: {
            recurse: true,
            include: "{*.json,*.yml,*.yaml}",
          },
        },
        destination: {
          server: "https://kubernetes.default.svc",
          namespace: name,
        },
        syncPolicy: {
          automated: {
            enabled: true,
            prune: true,
            selfHeal: true,
            allowEmpty: false,
          },
        },
      },
    }
  ),
}
