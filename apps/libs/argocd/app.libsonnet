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
          path: "generated/%s" % name,
        },
        destination: {
          server: "https://kubernetes.default.svc",
          namespace: name,
        },
      },
    }
  ),
}
