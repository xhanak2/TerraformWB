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

# service account


resource "google_service_account" "service_account_test1" {
  account_id   = "service-account-test1"
  display_name = "Service Account-test1"
}


resource "google_service_account" "service_account_test2" {
  account_id   = "service-account-test2"
  display_name = "Service Account-test2"
}


resource "google_service_account" "service_account_test3" {
  account_id   = "service-account-test3"
  display_name = "Service Account-test3"
}


