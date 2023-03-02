Kind           = "service-resolver"
Name           = "local-counter"
Namespace      = "default"
Failover = {
  "*" = {
    Datacenters = ["cluster-1"]
    // Datacenters = ["cluster-1", "cluster-2"]
  }
}