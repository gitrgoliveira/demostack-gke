Kind = "ingress-gateway"
Name = "dashboard-ingress-gateway"
Namespace = "default"

TLS {
  Enabled = true
}

Listeners = [
 {
   Port = 443
   Protocol = "tcp"
   Services = [
     {
        Name = "dashboard-service"
        Namespace = "dashboard-service"
     }
   ]
 }
]