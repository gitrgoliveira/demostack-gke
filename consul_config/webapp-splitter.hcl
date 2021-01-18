Kind = "service-splitter"
Name = "webapp"
Namespace = "webapp"
Splits = [
  {
    Weight  = 100
    Service = "webapp"
    Namespace = "webapp"
    ServiceSubset = "v1"
  },
  {
    Weight  = 0
    Service = "webapp"
    Namespace = "webapp"
    ServiceSubset = "v2"
  },
]