Ansible Collection - local.demo
===============================

Kubernetes MITM demo.

Included Content
----------------

Roles:

- `local.demo.networking` -- configure networking for the demo stand.
- `local.demo.swapoff` -- disable swap.
- `local.demo.containerd` -- install containerd.
- `local.demo.kubeadm` -- install kubelet, kubectl and kubeadm.
- `local.demo.controlplane` -- initialize Kubernetes control plane node.
- `local.demo.worker` -- initialize Kubernetes worker node.

Playbooks:

- `local.demo.ansible` -- install Ansible dependencies.
- `local.demo.stand` -- Configure the demo stand.

Requirements
------------

The `ansible-core` package is required. Tested with version 2.18.

The `ansible.posix` collection is required by the `local.demo.swapoff` role.

Author Information
------------------

Alexey Busygin \<yaabusygin@gmail.com\>
