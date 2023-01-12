terraform {
  backend "gcs" {
    bucket  = "pkslow-terraform"
    prefix  = "state/gcp/pubsub"
  }
}