terraform{
    backend "gcs" {
        bucket = "${google_storage_bucket.tf_state_bucket.name}"
        prefix = "terraform/state"
    }
}
resource "null_resource" "null" {
    triggers = {
        value = "Doing nothing"
    }
}
