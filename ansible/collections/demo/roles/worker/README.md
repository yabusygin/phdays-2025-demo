Ansible Role - local.demo.worker
================================

Initialize Kubernetes worker node.

Requirements
------------

None.

Role Variables
--------------

`worker_control_plane_node` -- control plane node host.

`worker_apiserver_address` -- IP address of the API Server.

Dependencies
------------

None.

Example Playbook
----------------

```yaml
- name: Example playbook
  hosts: worker-server
  tasks:
    - name: Initialize worker node
      ansible.builtin.import_role:
        name: local.demo.worker
      vars:
        worker_control_plane_node: control-plane-server
        worker_apiserver_address: 192.168.0.10
```
