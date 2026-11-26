1. Create K3S cluster without traefik
``` bash
curl -sfL https://get.k3s.io | sh -s - server --disable=traefik
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config
```

2. Download istio client
``` bash
curl -L https://istio.io/downloadIstio | sh -
cd istio-1.32.0
export PATH=$PWD/bin:$PATH
```

3. Verify
``` bash
$ istioctl version
Istio is not present in the cluster: no running Istio pods in namespace "istio-system"
client version: 1.32.0
```
4. Integrate istio with K3S cluster
``` bash
$ istioctl install --set profile=ambient --set values.global.platform=k3s --skip-confirmation
        |\          
        | \         
        |  \        
        |   \       
      /||    \      
     / ||     \     
    /  ||      \    
   /   ||       \   
  /    ||        \  
 /     ||         \ 
/______||__________\
____________________
  \__       _____/  
     \_____/        

✔ Istio core installed ⛵️                                                       
✔ CNI installed 🪢                                                              
✔ Istiod installed 🧠                                                           
✔ Ztunnel installed 🔒                                                          
✔ Installation complete                                                         
The ambient profile has been installed successfully, enjoy Istio without sidecars!
```

5. Install the Kubernetes Gateway API CRDs
``` bash
kubectl get crd gateways.gateway.networking.k8s.io &> /dev/null || \
  kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.6.1/experimental-install.yaml
```

6. Install ingressgateway
``` yaml
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
  name: ingress
spec:
  profile: empty
  components:
    ingressGateways:
      - name: istio-ingressgateway
        namespace: istio-ingress
        enabled: true
        label:
          istio: ingressgateway
  values:
    gateways:
      istio-ingressgateway:
        injectionTemplate: gateway
```

kubectl create namespace istio-ingress
istioctl install -f ingress.yaml 

6. Add label for your namespace, so that it will be managed by istio
   kubectl label namespace $NAMESPACE istio.io/dataplane-mode=ambient
 
8. Create gateway and virtual service for the target service
``` yaml
apiVersion: networking.istio.io/v1
kind: Gateway
metadata:
  name: grafana-gateway
  namespace: istio-system
spec:
  selector:
    istio: ingressgateway # Matches the label on your ingress gateway pod
  servers:
    - port:
        number: 80
        name: http-grafana
        protocol: HTTP
      hosts:
        - "grafana.k3s.local" # Or use "*" for quick local testing by IP
---
apiVersion: networking.istio.io/v1
kind: VirtualService
metadata:
  name: grafana-vs
  namespace: istio-system
spec:
  hosts:
    - "grafana.k3s.local" # Must match the Gateway host
  gateways:
    - grafana-gateway
  http:
    - route:
        - destination:
            host: grafana
            port:
              number: 3000
```


  




