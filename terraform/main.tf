resource "yandex_resourcemanager_folder" "folder" {
  cloud_id    = "${var.cloud_id}"
  name        = "bingo"
  description = "infra for app bingo"
}

resource "yandex_iam_service_account" "sa" {
  folder_id = yandex_resourcemanager_folder.folder.id
  name = "bingo-admin"
}

resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = yandex_resourcemanager_folder.folder.id
  role      = "admin"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
  depends_on = [
    yandex_iam_service_account.sa,
 ]
}

resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.sa.id
  description        = "static access key for object storage"
}

resource "yandex_storage_bucket" "bucket" {
  folder_id = yandex_resourcemanager_folder.folder.id
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = "bucketforapp"
  depends_on = [
    yandex_iam_service_account_static_access_key.sa-static-key
  ]
}

resource "yandex_vpc_network" "network" {
  folder_id = yandex_resourcemanager_folder.folder.id
  name = yandex_resourcemanager_folder.folder.name
  description = "Main network for ${yandex_resourcemanager_folder.folder.name}"
}

resource "yandex_vpc_subnet" "subnet" {
  folder_id = yandex_resourcemanager_folder.folder.id
  name           = "${yandex_resourcemanager_folder.folder.name}-ru-central1-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["10.0.10.0/24"]
  depends_on = [
    yandex_vpc_network.network,
  ]
}

resource "yandex_dns_zone" "zone1" {
  folder_id = yandex_resourcemanager_folder.folder.id
  name        = "commerce-store-zone"
  description = "commerce-store public zone"
  zone    = "commerce-store.ru."
  public  = true
}

data template_file "userdata" {
  template = file("./userdata.yaml")
  vars = {
    username           = var.ssh_login
    ssh_public_key     = var.ssh_public_key
  }
}


resource "yandex_compute_instance_group" "app" {
  name               = "app"
  folder_id = yandex_resourcemanager_folder.folder.id
  service_account_id = yandex_iam_service_account.sa.id
  depends_on = [
    yandex_iam_service_account.sa,
    yandex_resourcemanager_folder_iam_member.sa-editor,
    yandex_vpc_network.network,
    yandex_vpc_subnet.subnet,
  ]

  load_balancer {
    target_group_name = "app"
  }
  instance_template {
    name = "app-{instance.index}"
    resources {
      cores  = 2
      memory = 2
      core_fraction = 100
    }
    boot_disk {
      initialize_params {
        image_id = "fd80o2eikcn22b229tsa" 
        size     = 30
        type     = "network-hdd"
      }
    }
    network_interface {
      network_id     = yandex_vpc_network.network.id
      subnet_ids = [yandex_vpc_subnet.subnet.id]
      nat = true
    }
    metadata = {
      user-data = data.template_file.userdata.rendered
    }
    scheduling_policy {
      preemptible = true
    }
    network_settings {
      type = "STANDARD"
    }
  }

  scale_policy {
    fixed_scale {
      size = 2
    }
  }

  allocation_policy {
    zones = [
      "ru-central1-a",
    ]
  }

  deploy_policy {
    max_unavailable = 2
    max_creating    = 2
    max_expansion   = 2
    max_deleting    = 2
  }
}

resource "yandex_lb_network_load_balancer" "app-load-balancer" {
  folder_id = yandex_resourcemanager_folder.folder.id
  name = "app-load-balancer"
  depends_on = [
    yandex_compute_instance_group.app,
  ]

  listener {
    name = "app-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_compute_instance_group.app.load_balancer.0.target_group_id
    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = "/healthz"
      }
    }
  }
}

resource "yandex_mdb_postgresql_cluster" "pg" {
  folder_id = yandex_resourcemanager_folder.folder.id
  name                = "bingopg"
  environment         = "PRESTABLE"
  network_id          = yandex_vpc_network.network.id
  security_group_ids  = [ yandex_vpc_security_group.pgsql-sg.id ]
  deletion_protection = false

  config {
    version = 16
    resources {
      resource_preset_id = "s2.micro"
      disk_type_id       = "network-ssd"
      disk_size          = "20"
    }
  }

  host {
    zone      = "ru-central1-a"
    name      = "pg-host-a"
    subnet_id = yandex_vpc_subnet.subnet.id
  }
}

resource "yandex_mdb_postgresql_user" "user" {
  cluster_id = yandex_mdb_postgresql_cluster.pg.id
  name       = "bingouser"
  password   = "user1user1"
}

resource "yandex_mdb_postgresql_database" "db" {
  cluster_id = yandex_mdb_postgresql_cluster.pg.id
  name       = "bingodb"
  owner      = "bingouser"
}

resource "yandex_vpc_security_group" "pgsql-sg" {
  folder_id = yandex_resourcemanager_folder.folder.id
  name       = "pgsql-sg"
  network_id = yandex_vpc_network.network.id

  ingress {
    description    = "PostgreSQL"
    port           = 6432
    protocol       = "TCP"
    v4_cidr_blocks = [ "0.0.0.0/0" ]
  }
}