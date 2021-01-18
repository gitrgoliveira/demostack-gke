Kind = "service-router"
Name = "webapp"
Namespace = "webapp"
Routes = [
  {
    Match {
      HTTP {
        QueryParam = [
          {
            Name  = "x-debug"
            Present = "True"
          },
        ]
      }
    }
    Destination {
      Service = "webapp"
      Namespace = "webapp"
      ServiceSubset = "v2"
    }
  }
]