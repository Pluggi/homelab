{
  local this = self,

  // TODO: Write doc. Obj must have metadata.name. We assume kind and apiVersion exist
  computeFilename(obj)::
    assert std.objectHas(obj, "metadata") && std.objectHas(obj.metadata, "name")
           : "Kubernetes resource is missing .metadata.name\n" + std.manifestJsonEx(obj, "  ");

    local fmt = {
      kind: std.asciiLower(obj.kind),
      name: std.asciiLower(obj.metadata.name),
    };

    local parents = this.parentDirectories(obj);

    std.join("/", parents + ["%(kind)s-%(name)s.yaml" % fmt])
  ,

  parentDirectories(obj)::
    local parents = [];

    local metadata = std.get(obj, "metadata", {});
    local labels = std.get(metadata, "labels", {});

    local team = std.get(labels, "team", null);
    local svc = std.get(labels, "svc", null);

    [team, svc]
  ,

  isKubernetesResource(o)::
    std.objectHas(o, "kind") && std.objectHas(o, "apiVersion")
  ,

  // "#find":: d.fn(|||
  //   Returns a dictionnary of all Kubernetes resources found in obj.
  //   The key of each Kubernetes resources can be modified by passing computeFilenameFn
  // |||, [
  //   d.arg("obj", d.T.object),
  //   d.arg("computeFilenameFn", d.T.func),
  // ]),
  exportKubernetesManifests(obj, computeFilenameFn=this.computeFilename)::
    if std.isObject(obj) then
      local selfResult = if this.isKubernetesResource(obj) then
        { [computeFilenameFn(obj)]: std.manifestJsonEx(obj, "  ") }
      else
        {}
      ;

      std.foldl(
        function(acc, val) acc + this.exportKubernetesManifests(val),
        std.objectValues(obj),
        selfResult
      )

    else if std.isArray(obj) then
      std.foldl(
        function(acc, elem) acc + this.exportKubernetesManifests(elem),
        obj,
        {}
      )

    else
      {},
}
