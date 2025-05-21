wait_vm_start = 30

all: ssh-keys images stand

ssh-keys: ssh/id_ed25519

images: debian malicious

debian: images/virtualbox/debian/output/debian.ova

malicious: images/container/malicious/output/malicious.tar

stand: gateway control-plane workers

gateway: images/virtualbox/debian/output/debian.ova ssh/id_ed25519
	VBoxManage import \
		$< \
		--vsys=0 \
		--group=/phdays-2025-demo \
		--vmname=gateway
	VBoxManage modifyvm \
		gateway \
		--natpf1="SSH,tcp,127.0.0.1,22001,,22"
	VBoxManage modifyvm \
		gateway \
		--nic2=intnet \
		--intnet2=phdays-2025-demo
	VBoxManage startvm --type=headless gateway
	sleep $(wait_vm_start)
	ansible-playbook --limit=gateway local.demo.ansible
	ansible-playbook --limit=gateway local.demo.stand

control-plane: images/virtualbox/debian/output/debian.ova ssh/id_ed25519
	VBoxManage import \
		$< \
		--vsys=0 \
		--group=/phdays-2025-demo \
		--vmname=control-plane \
		--cpus=2 \
		--memory=4096
	VBoxManage modifyvm \
		control-plane \
		--natpf1="SSH,tcp,127.0.0.1,22010,,22"
	VBoxManage modifyvm \
		control-plane \
		--natpf1="Kubernetes API,tcp,127.0.0.1,6443,,6443"
	VBoxManage modifyvm \
		control-plane \
		--nic2=intnet \
		--intnet2=phdays-2025-demo
	VBoxManage startvm --type=headless control-plane

	sleep $(wait_vm_start)

	ansible-playbook --limit=control-plane local.demo.ansible
	ansible-playbook --limit=control-plane local.demo.stand

	scp -F ssh/config control-plane:/etc/kubernetes/admin.conf kubeconfig.yml
	sed -i '' -e 's/192\.168\.78\.10/control-plane/' kubeconfig.yml

	kubectl create --kustomize=k8s/tigera-operator --kubeconfig=kubeconfig.yml
	kubectl create --kustomize=k8s/calico --kubeconfig=kubeconfig.yml

workers: images/virtualbox/debian/output/debian.ova ssh/id_ed25519 images/container/malicious/output/malicious.tar
	VBoxManage import \
		$< \
		--vsys=0 \
		--group=/phdays-2025-demo \
		--vmname=worker-alice-1 \
		--cpus=1 \
		--memory=2048
	VBoxManage modifyvm \
		worker-alice-1 \
		--natpf1="SSH,tcp,127.0.0.1,22011,,22"
	VBoxManage modifyvm \
		worker-alice-1 \
		--nic2=intnet \
		--intnet2=phdays-2025-demo
	VBoxManage startvm --type=headless worker-alice-1

	VBoxManage import \
		$< \
		--vsys=0 \
		--group=/phdays-2025-demo \
		--vmname=worker-alice-2 \
		--cpus=1 \
		--memory=2048
	VBoxManage modifyvm \
		worker-alice-2 \
		--natpf1="SSH,tcp,127.0.0.1,22012,,22"
	VBoxManage modifyvm \
		worker-alice-2 \
		--nic2=intnet \
		--intnet2=phdays-2025-demo
	VBoxManage startvm --type=headless worker-alice-2

	VBoxManage import \
		$< \
		--vsys=0 \
		--group=/phdays-2025-demo \
		--vmname=worker-mallory \
		--cpus=1 \
		--memory=2048
	VBoxManage modifyvm \
		worker-mallory \
		--natpf1="SSH,tcp,127.0.0.1,22013,,22"
	VBoxManage modifyvm \
		worker-mallory \
		--nic2=intnet \
		--intnet2=phdays-2025-demo
	VBoxManage startvm --type=headless worker-mallory

	sleep $(wait_vm_start)

	ansible-playbook --limit=workers local.demo.ansible
	ansible-playbook --limit=workers local.demo.stand

	scp -F ssh/config images/container/malicious/output/malicious.tar worker-mallory:malicious.tar
	ssh -F ssh/config worker-mallory ctr --namespace=k8s.io image import malicious.tar
	ssh -F ssh/config worker-mallory rm malicious.tar

	kubectl apply --filename=k8s/workload.yml --kubeconfig=kubeconfig.yml

networkpolicy:
	kubectl apply --filename=k8s/hostnetworkpolicy.yml --kubeconfig=kubeconfig.yml
	kubectl apply --filename=k8s/hostnetworkpolicy-deny-mallory.yml --kubeconfig=kubeconfig.yml
	kubectl apply --filename=k8s/hostendpoint.yml --kubeconfig=kubeconfig.yml
	kubectl apply --filename=k8s/networkpolicy.yml --kubeconfig=kubeconfig.yml

ssh/id_ed25519:
	ssh-keygen -t ed25519 -C root@phdays-2025-demo.test -N '' -f $@

images/virtualbox/debian/output/debian.ova: ssh/id_ed25519
	packer build images/virtualbox/debian

images/container/malicious/output/malicious.tar:
	docker image build --tag=phdays-2025-demo.test/malicious:latest images/container/malicious/build
	mkdir $(dir $@)
	docker image save --output=$@ phdays-2025-demo.test/malicious:latest
	docker image rm phdays-2025-demo.test/malicious:latest

poweroff-vms:
	VBoxManage controlvm worker-mallory poweroff
	VBoxManage controlvm worker-alice-2 poweroff
	VBoxManage controlvm worker-alice-1 poweroff
	VBoxManage controlvm control-plane poweroff
	VBoxManage controlvm gateway poweroff

clean-all: clean-vms clean-images clean-ssh-keys

clean-vms: poweroff-vms
	VBoxManage unregistervm worker-mallory --delete-all
	VBoxManage unregistervm worker-alice-2 --delete-all
	VBoxManage unregistervm worker-alice-1 --delete-all
	VBoxManage unregistervm control-plane --delete-all
	VBoxManage unregistervm gateway --delete-all
	$(RM) kubeconfig.yml

clean-images:
	$(RM) -r images/container/malicious/output images/virtualbox/debian/output

clean-ssh-keys:
	$(RM) ssh/id_ed25519 ssh/id_ed25519.pub

test:
	ansible-lint ansible/collections/

.PHONY: all images debian malicious test gateway control-plane workers stand networkpolicy clean-vms clean-all poweroff-vms clean-images clean-ssh-keys
