# Drain worker node in K3S
```
kubectl drain k3s-worker1 k3s-worker2 k3s-worker3 --ignore-daemonsets --delete-emptydir-data
```

**Stop k3s-agent on all worker node** 


**Monitoring node status, make sure all node status are NorReady**


**Power off all agent node**

