Ansible Role - local.demo.containerd
====================================

Install container runtime -- containerd.

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
    - name: Install container runtime
      ansible.builtin.import_role:
        name: local.demo.containerd
```
