Kind = "ingress-gateway"
Name = "webapp-cluster-1-ig"
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
        Hosts = [ "webapp-cluster-1.ric.gcp.hashidemos.io"]
     }
   ]
 }
]