
variable "billing_account" {}
variable "org_id" {}
variable "region" {}

provider "google" {
  region = var.region
}

resource "random_id" "id" {
  byte_length = 4

}

locals{
  uid = lower(random_id.id.hex)
}

resource "google_project" "project" {
  name            = "jessy-cloud-${locals.uid}"
  project_id      = random_id.id.hex
  billing_account = var.gcp_billing_account
}


resource "google_service_account" "myaccount"{
  account_id = "jessy-service-acount"
  project = google_project.project.project_id
  display_name = "Jessy's Service account for Github action Pipeline "

}

resource "google_service_account_key" "mykey" {
  service_account_id = google_service_account.myaccount.name
  keepers = {
    rotation_time = time_rotating.mykey_rotation.rotation_rfc3339
  }
}

# Note this requires the terraform to be run regularly
resource "time_rotating" "mykey_rotation"{
  rotation_days = 7
}

#Assign service account the owner's role
resource "google_project_iam_member" "assign_sa_owner_role"{
  project = google_project.project.project_id
  role = "roles/owner"
  member = "serviceAccount:${google_service_account.myaccount.email}"

}

resource "google_storage_bucket" "tf_state_bucket"{
  project = google_project.project.project_id
  name = "${google_project.project.project_id}-tf-state"
  location = "EU"
  force_destroy = true
  uniform_bucket_level_access = true
}