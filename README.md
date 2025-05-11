# Getting Started

### Running the Application

```
./gradlew bootRun
```

Open [http://localhost:8080](http://localhost:8080) in your browser.

### Building the Application

```
./gradlew bootJar
```

### Running the Application as a Docker Container

```
...
java -jar ./build/libs/tech-challenge-0.0.1-SNAPSHOT.jar
```

### Requirements

1. This project should be made to run as a Docker image.
2. Docker image should be published to a Docker registry.
3. Docker image should be deployed to a Kubernetes cluster.
4. Kubernetes cluster should be running on a cloud provider.
5. Kubernetes cluster should be accessible from the internet.
6. Kubernetes cluster should be able to scale the application.
7. Kubernetes cluster should be able to update the application without downtime.
8. Kubernetes cluster should be able to rollback the application to a previous version.
9. Kubernetes cluster should be able to monitor the application.
10. Kubernetes cluster should be able to autoscale the application based on the load.

### Additional
1. Application logs should be stored in a centralised logging system (Loki, Kibana, etc.)
2. Application should be able to send metrics to a monitoring system.
3. Database should be running on a separate container.
4. Storage should be mounted to the database container.


### Start your Kubernetes cluster (if it's not running already)

```
minikube start
```
### Navigate to your project directory

```
cd C:\Users\user\Desktop\Cloud_App\cloud-app
```

### Apply the deployment

```
kubectl apply -f deployment.yaml
```

### Apply the ingress configuration

```
kubectl apply -f ingress.yaml
```

### Apply the hpa configuration

```
kubectl apply -f hpa.yaml
```



### Verify that everything is up. Check deployments

```
kubectl get deployments
```

### Verify that everything is up. Check pods

```
kubectl get pods
```

### Verify that everything is up. Check services

```
kubectl get svc
```

### Verify that everything is up. Check ingress (confirm external IP)

```
kubectl get ingress
```

### Verify that everything is up. Check the HPA status

```
kubectl get hpa
```


### Port-forward to test if needed:

```
kubectl port-forward service/cloud-app-service 8080:80
```

### Then test in browser or with curl:

```
curl http://localhost:8080
```

### Start ngrok to expose the app to the internet
```
ngrok http 8080
```

or 

```
ngrok http http://localhost:8080
```


### Create (recreate) load generator
```
kubectl delete pod load-generator
kubectl apply -f load-generator.yaml
```

### Monitor autoscaling (dynamic autoscaling) and WAIT!

```
while ($true) { kubectl get hpa; Start-Sleep -Seconds 10 }
```

