output "cli_connect_command" {
  description = "The gcloud command to run for getting kubectl"
  value = "gcloud container clusters get-credentials ${module.kubernetes-engine.name} --region ${var.location} --project ${var.project_id}"
}