terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
 }
}

provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

resource "google_compute_instance_template" "instance_template" {
  name  = "vmtemplate"
  machine_type = "f1-micro"
  description = "Maquina de teste"
  metadata_startup_script = file("startupscript")
  tags = ["ssh","http"]


    disk {
     #initialize_params {
       source_image = "debian-cloud/debian-9"

    }

  

  
  network_interface {
    # A default network is created for all GCP projects
    network = "default"
      
  }

    
}




resource "google_compute_health_check" "autohealing" {
  name                = "autohealing-health-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10 # 50 seconds

  http_health_check {
    request_path = "/healthz"
    port         = "8080"
  }
}

resource "google_compute_instance_group_manager" "vmtemplate" {
  name = "instgroup"

  base_instance_name = "inst"
  zone               = "southamerica-east1-b"

  version {
    instance_template  = google_compute_instance_template.instance_template.id
  }

  #target_pools = [google_compute_target_pool.instance_template.id]
  #target_size  = 2

  named_port {
    name = "customHTTP"
    port = 80
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.autohealing.id
    initial_delay_sec = 300
  }
}
#gcloud compute --project=sd-infraestrutura instance-groups managed create instance-group-1 --base-instance-name=instance-group-1 --template=vmtemplate --size=1 --zone=southamerica-east1-b

#gcloud beta compute --project "sd-infraestrutura" instance-groups managed set-autoscaling "instance-group-1" --zone "southamerica-east1-b" --cool-down-period "60" --max-num-replicas "10" --min-num-replicas "1" --target-cpu-utilization "0.6" --mode "on"
