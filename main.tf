############################
# Provider
############################
provider "google" {
  project = "durable-catbird-450018-j4"
  region  = "us-central1"
}

############################
# VPC Network
############################
resource "google_compute_network" "privategpt_vpc" {
  name                    = "privategpt-vpc"
  auto_create_subnetworks = false
}

############################
# Subnets (2 subnets)
############################
resource "google_compute_subnetwork" "privategpt_subnet" {
  count         = 2
  name          = "privategpt-subnet-${count.index}"
  ip_cidr_range = cidrsubnet("10.0.0.0/16", 8, count.index)
  region        = "us-central1"
  network       = google_compute_network.privategpt_vpc.id
}

############################
# Firewall Rules (instead of Security Groups)
############################
resource "google_compute_firewall" "allow_all_internal" {
  name    = "allow-internal"
  network = google_compute_network.privategpt_vpc.name

  allow {
    protocol = "all"
  }

  source_ranges = ["10.0.0.0/16"]
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.privategpt_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

############################
# GKE Cluster
############################
resource "google_container_cluster" "privategpt" {
  name     = "privategpt-cluster"
  location = "us-central1"

  network    = google_compute_network.privategpt_vpc.name
  subnetwork = google_compute_subnetwork.privategpt_subnet[0].name

  remove_default_node_pool = true
  initial_node_count       = 1

  ip_allocation_policy {}
}

############################
# Node Pool (Equivalent to Node Group)
############################
resource "google_container_node_pool" "privategpt_nodes" {
  name       = "privategpt-node-pool"
  cluster    = google_container_cluster.privategpt.name
  location   = "us-central1"

  node_count = 1

  autoscaling {
    min_node_count = 1
    max_node_count = 2
  }

  node_config {
    machine_type = "e2-micro"
    disk_size_gb = 10

    service_account = terraform-sa@durable-catbird-450018-j4.iam.gserviceaccount.com

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    tags = ["gke-node"]
  }
}
