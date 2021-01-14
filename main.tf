terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "3.5.0"
    }
  }
}

provider "google" {

  #credentials = var.client_secret
  credentials = file("phanak-testgke1-052d683d9658.json")
  project = "phanak-testgke1"
  region  = "us-central1"
  zone    = "us-central1-c"
}


variable "project_id" {
  default="phanak-testgke1"
  description = "project id"
}

variable "region" {
  default="us-central1"
  description = "region"
}

variable "gke_username" {
  default     = ""
  description = "gke username"
}

variable "gke_password" {
  default     = ""
  description = "gke password"
}

variable "gke_num_nodes" {
  default     = 1
  description = "number of gke nodes"
}

#variable "client_secret" {
#  default = ""
#  description = "json secret to GCP"
#}

# VPC
resource "google_compute_network" "vpctest2" {
  name                    = "${var.project_id}-vpctest2"
  auto_create_subnetworks = "false"
}

# Subnet
resource "google_compute_subnetwork" "subnettest2" {
  name          = "${var.project_id}-subnettest2"
  region        = var.region
  network       = google_compute_network.vpctest2.name
  ip_cidr_range = "10.20.0.0/24"

}

output "region" {
  value       = var.region
  description = "region"
}


# GKE cluster
resource "google_container_cluster" "primary" {
  name     = "${var.project_id}-gke2"
  location = "${var.region}-a"

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.vpctest2.name
  subnetwork = google_compute_subnetwork.subnettest2.name

  master_auth {
    username = var.gke_username
    password = var.gke_password

    client_certificate_config {
      issue_client_certificate = false
    }
  }
}

# Separately Managed Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name       = "${google_container_cluster.primary.name}-node-pool"
  #location   = var.region
  location = "${var.region}-a"
  cluster    = google_container_cluster.primary.name
  #node_count = var.gke_num_nodes
  node_count = 1
  autoscaling {
    min_node_count=1
    max_node_count=1
  }
  
  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/cloud-platform"
      ,
    ]

    labels = {
      env = var.project_id
    }

    preemptible  = true
    machine_type = "n1-standard-1"
    tags         = ["gke-node", "${var.project_id}-gke2"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

output "kubernetes_cluster_name" {
  value       = google_container_cluster.primary.name
  description = "GKE Cluster Name"
}
