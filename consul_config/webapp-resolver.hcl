Kind          = "service-resolver"
Name          = "webapp"
Namespace     = "webapp"
DefaultSubset = "v1"
Subsets = {
  "v1" = {
    Filter = "Service.Meta.version == v1"
  }
  "v2" = {
    Filter = "Service.Meta.version == v2"
  }
}
Redirect {
  Service    = "webapp"
  Datacenter = "cluster-1"
  Namespace  = "webapp"
}