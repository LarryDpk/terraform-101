provider "google" {
  project     = "pkslow"
}

resource "google_pubsub_topic" "pkslow-poc" {
  name = "pkslow-poc"
}

resource "google_pubsub_subscription" "pkslow-poc" {
  name  = "pkslow-poc"
  topic = google_pubsub_topic.pkslow-poc.name

  labels = {
    foo = "bar"
  }

  # 20 minutes
  message_retention_duration = "1200s"
  retain_acked_messages      = true

  ack_deadline_seconds = 20

  expiration_policy {
    ttl = "300000.5s"
  }
  retry_policy {
    minimum_backoff = "10s"
  }

  enable_message_ordering    = true
}