Ansible Role - local.demo.kubeadm
=================================

Install kubelet, kubectl and kubeadm.

Requirements
------------

None.

Role Variables
--------------

None.

Dependencies
------------

None.

Example Playbook
----------------

```yaml
- name: Example playbook
  hosts: server
  tasks:
    - name: Install kubelet, kubectl and kubeadm
      ansible.builtin.import_role:
        name: local.demo.kubeadm
```
