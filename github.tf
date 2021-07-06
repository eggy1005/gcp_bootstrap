provider "github"{
    token = var.github_token
    owner = var.github_owner
}

resource "github_repository" "infra"{
    name = "infra"
    visibility = "public"
    auto_init = true
}

resource "github_branch" "jessyimpl"{
    repository = github_repository.infra.name
    branch = "jessyimpl"
}

resource "github_actions_secret" "myaccount"{
    repository = github_repository.infra.name
    secret_name = "GCP_SA_KEY"
    plaintext_value = base64decode(google_service_account_key.mykey.private_key)

}

resource "github_actions_secret" "project_id"{
    repository = github_repository.infra.name
    secret_name = "GCP_PROJECT_ID"
    plaintext_value = google_project.project.project_id
}

resource "github_repository_file" "tf_action_file"{
    repository = github_repository.infra.name
    branch = github_branch.jessyimpl.branch
    file = ".github/workflows/terraform.yml"
    content = file("${path.module}/template/terraform.yml")

}

resource "github_repository_file" "tf_main_file" {
    repository = github_repository.infra.name
    branch = github_branch.jessyimpl.branch
    file = "main.tf"
    content = templatefile("${path.module}/template/main.tf", {
        bucket_name = google_storage_bucket.tf_state_bucket.name
    })
}