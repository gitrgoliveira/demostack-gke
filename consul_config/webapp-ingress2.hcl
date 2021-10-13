Kind = "ingress-gateway"
Name = "webapp-cluster-2-ig"
Namespace = "default"

TLS {
  Enabled = true
}

Listeners = [
 {
   Port = 443
   Protocol = "http"
   Services = [
     {
        Name = "webapp"
        Namespace = "webapp"
        Hosts = ["webapp-cluster-2.ric.gcp.hashidemos.io" ]
     }
   ]
 }
]