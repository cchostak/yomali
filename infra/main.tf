terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
  alias   = "dev"
  project = "yomali"
  region  = "europe-west2"
  zone    = "europe-west2-c"
}

provider "google-beta" {
  alias   = "dev"
  project = "yomali"
  region  = "europe-west2"
  zone    = "europe-west2-c"
}

resource "google_compute_network" "yomali-vpc" {
  provider                = google
  project                 = "yomali"
  name                    = "yomali-vpc"
  auto_create_subnetworks = true
}

resource "google_compute_instance" "bastion" {
  provider     = google
  project      = "yomali"
  name         = "bastion"
  machine_type = "e2-micro"
  zone         = "europe-west2-c"
  tags         = ["bastion"]

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  scheduling {
    provisioning_model = "STANDARD"
    automatic_restart  = true
  }

  boot_disk {
    mode        = "READ_WRITE"
    auto_delete = true
    initialize_params {
      image = "ubuntu-minimal-2204-jammy-v20220816"
      type  = "pd-balanced"
    }
  }

  metadata = {
    ssh-keys                 = "${var.ssh-user}:${var.ssh-key}"
    block-project-ssh-keys   = false
    gce-software-declaration = <<-EOF
        {
          "softwareRecipes": [{
            "name": "install-ansible",
            "desired_state": "INSTALLED",
            "installSteps": [{
              "scriptRun": {
                "script": "apt-get install ansible mysql-client -y"
              }
            }]
          }]
        }
        EOF
  }

  network_interface {
    network = google_compute_network.yomali-vpc.id
    access_config {
    }
  }
}

resource "google_compute_instance" "haproxy" {
  provider     = google
  project      = "yomali"
  name         = "haproxy"
  machine_type = "e2-micro"
  zone         = "europe-west2-c"
  tags         = ["haproxy"]

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  scheduling {
    provisioning_model = "STANDARD"
    automatic_restart  = true
  }

  boot_disk {
    mode        = "READ_WRITE"
    auto_delete = true
    initialize_params {
      image = "ubuntu-minimal-2204-jammy-v20220816"
      type  = "pd-balanced"
    }
  }

  metadata = {
    ssh-keys               = "${var.ssh-user}:${var.ssh-key}"
    block-project-ssh-keys = false
  }

  network_interface {
    network = google_compute_network.yomali-vpc.id
  }
}

resource "google_compute_instance" "mysql" {
  provider     = google
  project      = "yomali"
  name         = "mysql"
  machine_type = "e2-micro"
  zone         = "europe-west2-c"
  tags         = ["mysql"]

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  scheduling {
    provisioning_model = "STANDARD"
    automatic_restart  = true
  }

  boot_disk {
    mode        = "READ_WRITE"
    auto_delete = true
    initialize_params {
      image = "ubuntu-minimal-2204-jammy-v20220816"
      type  = "pd-balanced"
    }
  }

  metadata = {
    ssh-keys               = "${var.ssh-user}:${var.ssh-key}"
    block-project-ssh-keys = false
  }

  network_interface {
    network = google_compute_network.yomali-vpc.id
  }
}

resource "google_compute_project_metadata" "ssh-key" {
  project = "yomali"

  metadata = {
    ssh-keys = var.ssh-key
  }
}

resource "google_compute_firewall" "ssh-from-dc" {
  project = "yomali"

  name    = "ssh-from-dc"
  network = google_compute_network.yomali-vpc.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags   = ["bastion"]
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "ssh-from-bastion" {
  project = "yomali"

  name    = "ssh-from-bastion"
  network = google_compute_network.yomali-vpc.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags   = ["haproxy", "mysql"]
  source_ranges = [google_compute_instance.bastion.network_interface.0.network_ip]
}

resource "google_compute_firewall" "mysql-from-bastion" {
  project = "yomali"

  name    = "mysql-from-bastion"
  network = google_compute_network.yomali-vpc.id

  allow {
    protocol = "tcp"
    ports    = ["3306"]
  }

  target_tags   = ["haproxy", "mysql"]
  source_ranges = [google_compute_instance.bastion.network_interface.0.network_ip]
}


resource "google_compute_router" "router" {
  project = "yomali"

  name    = "router"
  network = google_compute_network.yomali-vpc.id
  region  = "europe-west2"
}

resource "google_compute_router_nat" "nat" {
  project = "yomali"

  name                               = "nat"
  router                             = google_compute_router.router.name
  region  = "europe-west2"
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

output "bastion-connection-string" {
  description = "Command to connect to the compute instance"
  value       = "ssh -i <pkey> ${var.ssh-user}@${google_compute_instance.bastion.network_interface.0.access_config.0.nat_ip} ${var.host-check} ${var.ignore-known-hosts}"
  sensitive   = false
}