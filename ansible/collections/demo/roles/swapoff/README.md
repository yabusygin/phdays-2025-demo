Ansible Role - local.demo.swapoff
=================================

Disable swap.

Requirements
------------

None.

Role Variables
--------------

None.

Dependencies
------------

The `ansible.posix` collection is required.

Example Playbook
----------------

```yaml
- name: Example playbook
  hosts: server
  tasks:
    - name: Disable swap
      ansible.builtin.import_role:
        name: local.demo.swapoff
```
