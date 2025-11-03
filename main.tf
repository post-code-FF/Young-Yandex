terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.90"
    }
  }
}

provider "yandex" {
  token     = "t1.9euelZqRmY3MlMebjpbMkpaJmZuZi-3rnpWam52YyM3Nx46OzpvJyJXIi5zl8_c3U2M7-e8OQDVA_d3z93cBYTv57w5ANUD9zef1656VmsaTjs3GnciSk5PNmZ6azcqO7_zF656VmsaTjs3GnciSk5PNmZ6azcqO.H4EGRkaYx8JcWT90dzL8IlpMrORbBQ3gDyBqjMDMX3vtu3cOVQ8EmbgcmJ2tfQMfJxZOyNYT8a_eey_Pa1VdAg"
  cloud_id  = "b1guelj93thdj8g5v6v8"
  folder_id = "b1g8bhea8jjaic4ei21d"
  zone      = "ru-central1-a"
}

resource "yandex_vpc_network" "k8s-network" {
  name = "k8s-network"
}

resource "yandex_vpc_route_table" "rt" {
  name = "k8s-route-table"
  network_id = yandex_vpc_network.k8s-network.id
}

resource "yandex_vpc_subnet" "k8s-subnet" {
  name = "k8s-subnet"
  zone = "ru-central1-a"
  network_id = yandex_vpc_network.k8s-network.id
  route_table_id = yandex_vpc_route_table.rt.id
  v4_cidr_blocks = ["10.10.0.0/16"]
}

resource "yandex_kubernetes_cluster" "k8s-cluster" {
  name = "my-k8s-cluster"
  network_id = yandex_vpc_network.k8s-network.id
  master {
	  zonal {
	    zone = "ru-central1-a"
	    subnet_id = yandex_vpc_subnet.k8s-subnet.id
	}
	public_ip = true
      }

      service_account_id = "aje5ro821u1aiotagrjh"
      node_service_account_id = "ajeanqkke0l40ss4762l"
      release_channel = "STABLE"
}

resource "yandex_kubernetes_node_group" "k8s-nodes" {
  cluster_id = yandex_kubernetes_cluster.k8s-cluster.id
  name       = "k8s-node-group"
  version    = "1.29" 

  node_labels = {
    "env" = "dev"
  }

  allocation_policy {
    location {
      zone = "ru-central1-a"
    }
  }

  instance_template {
    platform_id = "standard-v2"
    resources {
      cores  = 2
      memory = 4
    }
    boot_disk {
      type = "network-hdd"
      size = 30
    }
    network_interface {
      subnet_ids = [yandex_vpc_subnet.k8s-subnet.id]
      nat        = true
    }
    scheduling_policy {
      preemptible = true
    }
  }

  scale_policy {
    fixed_scale {
      size = 1
    }
  }

  node_taints = []
  labels = {
    "group" = "default"
  }
}
