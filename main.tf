############################
# Provider
############################
provider "google" {
  project = "durable-catbird-450018-j4"
  region  = "asia-south1"   # ✅ FIXED (region, not zone)
}

############################
# VPC Network
############################
resource "google_compute_network" "privategpt_vpc" {
  name                    = "privategpt-vpc"
  auto_create_subnetworks = false
}

############################
# Subnet
############################
resource "google_compute_subnetwork" "privategpt_subnet" {
  name          = "privategpt-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = "asia-south1"
  network       = google_compute_network.privategpt_vpc.id
}

############################
# Firewall Rules
############################
resource "google_compute_firewall" "allow_internal" {
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
# GKE Autopilot Cluster (FINAL FIX)
############################
resource "google_container_cluster" "privategpt" {
  name             = "privategpt-cluster"
  location         = "asia-south1"   # ✅ regional (Autopilot requirement)

  enable_autopilot = true            # 🔥 KEY FIX

  deletion_protection = false
}
