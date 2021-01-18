Kind           = "service-resolver"
Name           = "local-counter"
Namespace      = "default"
ConnectTimeout = "15s"
Redirect {
  Service    = "local-counter"
  Datacenter = "cluster-1"
}
Failover = {
  "*" = {
    Datacenters = ["cluster-1", "cluster-2"]
  }
}