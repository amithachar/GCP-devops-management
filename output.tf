output "cluster_id" {
  value = google_container_cluster.privategpt.id
}

output "cluster_name" {
  value = google_container_cluster.privategpt.name
}

output "cluster_endpoint" {
  value = google_container_cluster.privategpt.endpoint
}

output "vpc_id" {
  value = google_compute_network.privategpt_vpc.id
}

output "subnet_id" {
  value = google_compute_subnetwork.privategpt_subnet.id
}
