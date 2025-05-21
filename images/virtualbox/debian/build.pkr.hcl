packer {
  required_plugins {
    qemu = {
      version = "~> 1.1"
      source  = "github.com/hashicorp/virtualbox"
    }
  }
}

source "virtualbox-iso" "debian" {
  vm_name              = "debian"
  guest_os_type        = "Debian12_arm64"
  firmware             = "efi"
  rtc_time_base        = "UTC"
  cpus                 = 1
  memory               = 2 * 1024
  gfx_controller       = "vmsvga"
  gfx_vram_size        = 16
  hard_drive_interface = "virtio"
  disk_size            = 20 * 1024
  iso_interface        = "virtio"

  vboxmanage = [
    [
      "modifyvm", "{{.Name}}",
      "--chipset=armv8virtual",
      "--usb-xhci=on",
      "--keyboard=usb",
      "--mouse=usb",
    ],
    [
      "storagectl", "{{.Name}}",
      "--name", "IDE Controller",
      "--remove"
    ]
  ]

  headless = false

  iso_url      = "https://cdimage.debian.org/cdimage/release/current/arm64/iso-cd/debian-12.11.0-arm64-netinst.iso"
  iso_checksum = "sha512:892cf1185a214d16ff62a18c6b89cdcd58719647c99916f6214bfca6f9915275d727b666c0b8fbf022c425ef18647e9759974abf7fc440431c39b50c296a98d3"

  http_content = {
    "/preseed.cfg" = templatefile(
      "autoinstall/preseed.cfg.pkrtpl.hcl",
      {
        ssh_authorized_key = trimspace(file("${path.cwd}/ssh/id_ed25519.pub"))
      }
    )
  }

  boot_wait = "15s"

  # https://www.debian.org/releases/stable/arm64/apb.en.html
  boot_command = [
    "c",
    "<wait5>",
    "linux /install.a64/vmlinuz auto-install/enable=true debconf/priority=critical preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg<enter>",
    "<wait>",
    "initrd /install.a64/initrd.gz<enter>",
    "<wait>",
    "boot<enter>"
  ]

  ssh_username         = "root"
  ssh_private_key_file = "${path.cwd}/ssh/id_ed25519"
  ssh_timeout          = "20m"

  guest_additions_mode = "disable"

  shutdown_command = "shutdown --poweroff now"

  output_directory = "${path.root}/output"
  format           = "ova"
}

build {
  sources = ["virtualbox-iso.debian"]
}
