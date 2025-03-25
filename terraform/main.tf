provider "google" {
  project = "jupyter-notebook-454717"  
  region  = "europe-west2"     
  zone    = "europe-west2-b"   
}

resource "google_compute_instance" "notebook" {
  name         = "notebook"
  machine_type = "e2-medium"
  zone         = "europe-west2-b"   

  tags = ["http-server", "https-server", "ssh-server"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"  # Use Ubuntu 22.04 LTS
      size  = 20
      type  = "pd-balanced"
    }
  }

  network_interface {
    network = "default"
    access_config {}  
  }

  metadata = {
    enable-osconfig = "TRUE"
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]

  lifecycle {
    ignore_changes = [name]
  }
}
