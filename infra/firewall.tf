
resource "google_compute_firewall" "inu-dining-firewall" {
  name =  "inu-dining-firewall"
  network =  module.vpc.network_name


 source_ranges = ["0.0.0.0/0"]

  target_tags = ["gke-node"] # Make sure this matches your node pool tags

  allow {
    protocol = "tcp"
    ports    = ["4000"]
  }
}


