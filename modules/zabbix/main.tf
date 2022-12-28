## DATASOURCE
# Init Script Files

locals {
  zabbix_script       = "~/install_zabbix.sh"
  security_script = "~/configure_local_security.sh"
  create_zabbix_db    = "~/create_zabbix_db.sh"
  fault_domains_per_ad = 3
}


data "template_file" "install_zabbix" {
  template = file("${path.module}/scripts/install_zabbix.sh")
}

data "template_file" "configure_local_security" {
  template = file("${path.module}/scripts/configure_local_security.sh")
}

data "template_file" "create_zabbix_db" {
  template = file("${path.module}/scripts/create_zabbix_db.sh")
  vars = {
    admin_password  = var.admin_password
    admin_username  = var.admin_username
    zabbix_password = var.zabbix_password
    mds_ip          = var.mds_ip
    zabbix_name     = var.zabbix_name
    zabbix_schema   = var.zabbix_schema
  }
}


resource "oci_core_instance" "Zabbix" {
  compartment_id      = var.compartment_ocid
  display_name        = "${var.label_prefix}${var.display_name}"
  shape               = var.shape
  availability_domain = var.availability_domains[0] 
  fault_domain        = "FAULT-DOMAIN-1"

  dynamic "shape_config" {
    for_each = local.is_flexible_node_shape ? [1] : []
    content {
      memory_in_gbs = var.flex_shape_memory
      ocpus = var.flex_shape_ocpus
    }
  }

  create_vnic_details {
    subnet_id        = var.subnet_id
    display_name     = "${var.label_prefix}${var.display_name}"
    assign_public_ip = var.assign_public_ip
    hostname_label   = "${var.display_name}"
  }

  metadata = {
    ssh_authorized_keys = var.ssh_authorized_keys
  }

  source_details {
    source_id   = var.image_id
    source_type = "image"
  }

  provisioner "file" {
    content     = data.template_file.install_zabbix.rendered
    destination = local.zabbix_script

    connection  {
      type        = "ssh"
      host        = self.public_ip
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = var.ssh_private_key

    }
  }

  provisioner "file" {
    content     = data.template_file.configure_local_security.rendered
    destination = local.security_script

    connection  {
      type        = "ssh"
      host        = self.public_ip
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = var.ssh_private_key

    }
  }

 provisioner "file" {
    content     = data.template_file.create_zabbix_db.rendered
    destination = local.create_zabbix_db

    connection  {
      type        = "ssh"
      host        = self.public_ip
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = var.ssh_private_key

    }
  }


   provisioner "remote-exec" {
    connection  {
      type        = "ssh"
      host        = self.public_ip
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = var.ssh_private_key

    }

    inline = [
       "chmod +x ${local.zabbix_script}",
       "sudo ${local.zabbix_script}",
       "chmod +x ${local.security_script}",
       "sudo ${local.security_script}",
       "chmod +x ${local.create_zabbix_db}",
       "sudo ${local.create_zabbix_db}"
    ]

   }

  timeouts {
    create = "10m"

  }
}
