# 1. Create bridge netwrok
``` bash
sudo nmcli con add type bridge ifname br0 con-name br0
sudo nmcli con modify br0 ipv4.addresses 192.168.122.1/24 ipv4.method shared
sudo nmcli con up br0
```

# 2. Create K3S cluster on bridge network, disable traefik which is phased out 
``` bash
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --node-ip=192.168.122.1 --flannel-iface=br0 --disable=traefik" sh -
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config
```

# 3. Download istio client
``` bash
curl -L https://istio.io/downloadIstio | sh -
cd istio-1.32.0
export PATH=$PWD/bin:$PATH
```

# 4. Verify
``` bash
$ istioctl version
Istio is not present in the cluster: no running Istio pods in namespace "istio-system"
client version: 1.32.0
```
# 5. Integrate istio with K3S cluster
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

# 6. Install the Kubernetes Gateway API CRDs
``` bash
kubectl get crd gateways.gateway.networking.k8s.io &> /dev/null || \
  kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.6.1/experimental-install.yaml
```

# 7. Install Istio addons 
``` bash
cd /opt/istio-1.32.0
kybectl apply -f samples/addons
```

# 8. Create Kubernet Gateway 
``` YAML
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: observability-gateway
  namespace: istio-system
spec:
  gatewayClassName: istio
  listeners:
  - name: http
    port: 80
    protocol: HTTP
    allowedRoutes:
      namespaces:
        from: All
```
**if TLS is needed**
``` bash
kubectl create secret tls observability-tls   --cert=cert-k3s.local.crt --key=cert-k3s.local.key -n istio-system
```

``` YAML
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: observability-gateway
  namespace: istio-system
spec:
  gatewayClassName: istio
  listeners:
  - name: https
    port: 443
    protocol: HTTPS
    tls:
      mode: Terminate
      certificateRefs:
      - kind: Secret
        name: observability-tls
    allowedRoutes:
      namespaces:
        from: All
```


# 9. Create HTTPRote 
``` YAML
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: kiali-route
  namespace: istio-system
spec:
  parentRefs:
  - name: observability-gateway
  hostnames:
  - "kiali.k3s.local"
  rules:
  - backendRefs:
    - name: kiali
      port: 20001
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: grafana-route
  namespace: istio-system
spec:
  parentRefs:
  - name: observability-gateway
  hostnames:
  - "grafana.k3s.local"
  rules:
  - backendRefs:
    - name: grafana
      port: 3000
```
**Note: It shall work for any namespace/service, not limited Grafana and Kiali** 



