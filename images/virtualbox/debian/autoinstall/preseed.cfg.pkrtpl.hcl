#_preseed_V1

# Localization
d-i debian-installer/language string en_US:en
d-i debian-installer/country string RU
d-i debian-installer/locale select en_US.UTF-8
d-i keyboard-configuration/xkb-keymap select us

# Network configuration
d-i netcfg/choose_interface select auto
d-i netcfg/get_hostname string debian
d-i netcfg/get_domain string
d-i netcfg/hostname string debian

# Mirror settings
d-i mirror/protocol string http
d-i mirror/country string RU
d-i mirror/http/hostname string deb.debian.org
d-i mirror/http/directory string /debian
d-i mirror/http/proxy string
d-i mirror/suite string stable

# Account setup
d-i passwd/root-login boolean true
d-i passwd/root-password password 123
d-i passwd/root-password-again password 123

d-i passwd/make-user boolean true
d-i passwd/user-fullname string User #1
d-i passwd/username string u1
d-i passwd/user-password password 123
d-i passwd/user-password-again password 123
d-i passwd/user-uid string 1000

# Clock and time zone setup
d-i clock-setup/utc boolean true
d-i time/zone select Europe/Moscow
d-i clock-setup/ntp boolean true

# Partitioning
d-i partman-auto/method string lvm
d-i partman-auto-lvm/guided_size string max
d-i partman-lvm/confirm boolean true
d-i partman-lvm/confirm_nooverwrite boolean true
d-i partman-auto/choose_recipe select atomic
d-i partman-partitioning/confirm_write_new_label boolean true
d-i partman/choose_partition select finish
d-i partman/confirm boolean true
d-i partman/confirm_nooverwrite boolean true
d-i partman/mount_style select uuid

# Base system installation
d-i base-installer/install-recommends boolean true
d-i base-installer/kernel/image select linux-image-arm64

# Apt setup
d-i apt-setup/non-free boolean false
d-i apt-setup/contrib boolean false
d-i apt-setup/use_mirror boolean true
d-i apt-setup/services-select multiselect security, updates
d-i apt-setup/security_host string security.debian.org
d-i debian-installer/allow_unauthenticated boolean false

# Package selection
tasksel tasksel/first multiselect ssh-server
d-i pkgsel/include string
d-i pkgsel/upgrade select safe-upgrade
popularity-contest popularity-contest/participate boolean false

# Boot loader installation
d-i grub-installer/only_debian boolean true
d-i grub-installer/with_other_os boolean true
d-i grub-installer/bootdev string default
d-i debian-installer/add-kernel-opts string

# Finishing up the installation
d-i finish-install/keep-consoles boolean true
d-i finish-install/reboot_in_progress note
d-i cdrom-detect/eject boolean true
d-i debian-installer/exit/halt boolean false
d-i debian-installer/exit/poweroff boolean false

# Advanced options
# Fix guest boot on macOS/ARM host: https://forums.debian.net/viewtopic.php?t=160673
d-i preseed/late_command string \
    in-target sh -c "echo 'fs0:\\\\efi\\\\debian\\\\grubaa64.efi' > /boot/efi/startup.nsh"; \
    in-target mkdir --mode=u=rwx,g=,o= /root/.ssh; \
    in-target sh -c "echo '${ssh_authorized_key}' > /root/.ssh/authorized_keys"; \
    in-target chmod u=rw,g=,o= /root/.ssh/authorized_keys
