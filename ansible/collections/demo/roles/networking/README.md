Ansible Role - local.demo.networking
====================================

Configure base networking for the demo stand: interface addresses, default
gateway and IP packet forwarding.

Requirements
------------

None.

Role Variables
--------------

`networking_hostname` -- hostname (`/etc/hostname` and `/etc/hosts`).

`networking_mgmt_iface_name` -- name of the management network interface.

`networking_mgmt_iface_nat` -- enable NAT at management network interface.

`networking_k8s_iface_name` -- name of the Kubernetes network interface.

`networking_k8s_iface_cidr` -- IP address and prefix length (CIDR notation) of
the Kubernetes network interface.

`networking_k8s_gateway` -- IP address of the Kubernetes network default gateway.

Dependencies
------------

None.

Example Playbook
----------------

```yaml
- name: Example playbook
  hosts: server
  tasks:
    - name: Configure networking
      ansible.builtin.import_role:
        name: local.demo.networking
      vars:
        networking_hostname: "{{ inventory_hostname_short }}"
        networking_mgmt_iface_name: eth0
        networking_k8s_iface_name: eth1
        networking_k8s_iface_cidr: 192.168.0.10/24
        networking_k8s_gateway: 192.168.0.1
```
