PROFILE ?= hitcounter
NS      ?= hitcounter
IMAGE   ?= hitcounter-api:1.0.0

.PHONY: up build deploy status url test spread load logs down

up:      ## create the local cluster
	minikube start -p $(PROFILE) --driver=docker --cpus=2 --memory=4096
	minikube -p $(PROFILE) addons enable metrics-server

build:   ## build the image inside the cluster
	minikube -p $(PROFILE) image build -t $(IMAGE) app

deploy:  ## apply the minikube overlay
	kubectl apply -k k8s/overlays/minikube

status:  ## what is running
	kubectl -n $(NS) get pods,svc,pvc,hpa,ingress

url:     ## URL of the NodePort service
	minikube -p $(PROFILE) service api -n $(NS) --url

test:    ## smoke test
	./scripts/smoke-test.sh

spread:  ## show load balancing across Pods
	./scripts/spread.sh

load:    ## drive the autoscaler
	./scripts/load-test.sh

logs:    ## follow API logs
	kubectl -n $(NS) logs -f deploy/api

down:    ## delete the cluster
	minikube delete -p $(PROFILE)
