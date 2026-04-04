############################
# GKE Cluster Output
############################
output "cluster_id" {
  value = google_container_cluster.privategpt.id
}

############################
# Node Pool Output
############################
output "node_pool_id" {
  value = google_container_node_pool.privategpt_nodes.id
}

############################
# VPC Network Output
############################
output "vpc_id" {
  value = google_compute_network.privategpt_vpc.id
}

############################
# Subnet Output
############################
output "subnet_id" {
  value = google_compute_subnetwork.privategpt_subnet[*].id
}
