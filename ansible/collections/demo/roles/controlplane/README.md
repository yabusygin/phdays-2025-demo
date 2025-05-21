Ansible Role - local.demo.controlplane
======================================

Initialize Kubernetes control plane node.

Requirements
------------

None.

Role Variables
--------------

`controlplane_pod_network_cidr` -- IP address range (CIDR notation) for the pod
network.

`controlplane_apiserver_address` -- IP address the API Server will advertise
it's listening on.

Dependencies
------------

None.

Example Playbook
----------------

```yaml
- name: Example playbook
  hosts: server
  tasks:
    - name: Initialize control plane
      ansible.builtin.import_role:
        name: local.demo.controlplane
            vars:
        controlplane_pod_network_cidr: 172.29.0.0/16
        controlplane_apiserver_address: 192.168.0.10
```
