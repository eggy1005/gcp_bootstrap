terraform{
    backend "gcs"{
        bucket = "${bucket_name}"
        prefix = "terraform/state"
    }
}

resource "google_compute_network" "vpc_network" {
  name = "vpc-network"
}