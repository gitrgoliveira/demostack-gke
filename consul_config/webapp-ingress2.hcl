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
        Hosts = ["webapp-cluster-2.hc-7b910e3ece0c4fa386d0665927c.gcp.sbx.hashicorpdemo.com" ]
     }
   ]
 }
]