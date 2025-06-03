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

```
docker build -t aftenidaniela/cloud-app-test .
docker push aftenidaniela/cloud-app-test
kubectl set image deployment/cloud-app cloud-app=aftenidaniela/cloud-app-test


```

For Spring Boot app to be listening on the container's external interface in ```src\main\resources\application.properties``` make sure to have:

```
server.address=0.0.0.0
```

Then run the following again

```
./gradlew bootJar
docker build -t aftenidaniela/cloud-app:v4 .
docker push aftenidaniela/cloud-app:v4
kubectl set image deployment/cloud-app cloud-app=aftenidaniela/cloud-app:v4
```

Wait for the pod to be ready:

```
kubectl get pods -l app=cloud-app
```

Then try:

```
kubectl port-forward deployment/cloud-app 8080:8080
curl http://localhost:8080
```

### Rollback the application to a previous version

If you want to rollback to the previous version — for example, aftenidaniela/cloud-app (which may be v1 or latest) — run:

```
kubectl set image deployment/cloud-app cloud-app=aftenidaniela/cloud-app
```

Or to another specific version:

```
kubectl set image deployment/cloud-app cloud-app=aftenidaniela/cloud-app:v2
```

Then wait for it to update:
```
kubectl rollout status deployment/cloud-app
```

And verify:
```
kubectl get deployment cloud-app -o=jsonpath="{.spec.template.spec.containers[*].image}"
```

Also:
```
kubectl port-forward deployment/cloud-app 8080:8080
curl http://localhost:8080
```


### Monitor the application
```
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl top pods
kubectl top nodes
```



### After GitHub Action (before implementing update Kubernetes deployment image)

```
kubectl set image deployment/cloud-app cloud-app=aftenidaniela/cloud-app:<version>
kubectl rollout status deployment/cloud-app
kubectl port-forward service/cloud-app-service 8080:80
ngrok http 8080
```



### End result (Build Docker image + Tag Docker image for Docker Hub + Push Docker image + Update Kubernetes deployment image):

Have Docker open
```
minikube start
```

Open PowerShell as Administrator
```
Set-ExecutionPolicy RemoteSigned -Scope LocalMachine
cd .\actions-runner\
./run.cmd
```

Port forwarding:
```
kubectl port-forward deployment/cloud-app 8080:8080
```

And verify Docker image tag:
```
kubectl get deployment cloud-app -o=jsonpath="{.spec.template.spec.containers[*].image}"
```

Show pods:
```
kubectl get pods -w
```

## Code explanation



### ```.github\workflows\docker-deploy.yml```

La fiecare push pe main, el:
* Construiește aplicația Java cu Gradle.
* Creează un container Docker cu aplicația.
* Îl împinge pe Docker Hub.
* Actualizează un deployment Kubernetes cu imaginea nouă.


```
on:
  push:
    branches:
      - main
```
* Rulează workflow-ul doar la push pe branch-ul main.

```
jobs:
  build-and-push:
    runs-on: [self-hosted, Windows, X64]
```
* Jobul rulează pe un runner self-hosted pe Windows (care a fost configurat in GitHub Actions).

```
env:
      IMAGE_NAME: ${{ secrets.DOCKERHUB_USERNAME }}/cloud-app
```
* Variabilă de mediu IMAGE_NAME cu formatul:
```<docker-username>/cloud-app``` (de exemplu: ```aftenidaniela/cloud-app```).

```
steps:
    - name: Checkout code
      uses: actions/checkout@v3
```
* Ia codul sursă din repository.

```
- name: Set up JDK 17
      uses: actions/setup-java@v3
      with:
        java-version: '17'
        distribution: 'temurin'
```
* Configurează Java 17 (este folosit pentru a construi aplicația cu Gradle).

```
- name: Build with Gradle
      run: ./gradlew bootJar
```
* Rulează bootJar pentru a crea un .jar Spring Boot.

```
- name: Log in to DockerHub
      uses: docker/login-action@v2
      with:
        username: ${{ secrets.DOCKERHUB_USERNAME }}
        password: ${{ secrets.DOCKERHUB_TOKEN }}
```
* Face login la Docker Hub cu credentialele stocate în Secrets in GitHub.

```
- name: Extract short SHA for version tag
      id: vars
      shell: powershell
      run: |
        $sha = git rev-parse --short HEAD
        echo "sha_short=$sha" | Out-File -FilePath $env:GITHUB_OUTPUT -Encoding utf8 -Append
```
* Creează un “short SHA” (ex. a1b2c3d) pentru a fi folosit ca tag la imaginea Docker.

```
- name: Build Docker image
      shell: powershell
      run: |
        $tag = "${{ steps.vars.outputs.sha_short }}"
        docker build -t "${{ env.IMAGE_NAME }}:$tag" .
```
* Creează imaginea cu tag-ul short SHA.

```
- name: Tag Docker image for Docker Hub
      run: docker tag ${{ env.IMAGE_NAME }}:${{ steps.vars.outputs.sha_short }} ${{ secrets.DOCKERHUB_USERNAME }}/${{ env.IMAGE_NAME }}:${{ steps.vars.outputs.sha_short }}
      shell: powershell
```
* Adaugă un tag pentru Docker Hub (uneori e redundant, dar clarifică naming-ul).

```
- name: Push Docker image
      run: docker push ${{ env.IMAGE_NAME }}:${{ steps.vars.outputs.sha_short }}
      shell: powershell
```
* Face push pe Docker Hub.

```
- name: Update Kubernetes deployment image
      run: kubectl set image deployment/cloud-app cloud-app=${{ env.IMAGE_NAME }}:${{ steps.vars.outputs.sha_short }}
      shell: powershell
```
* Folosește kubectl să actualizeze Deployment-ul cloud-app în cluster-ul Kubernetes cu noua imagine.


Rezumat:
1. Push to main
2. Build Gradle -> .jar
3. docker build (cu short SHA tag)
4. docker push la Docker Hub
5. kubectl set image in K8s


### ```ingress.yaml```

* Ingress = resursă Kubernetes care gestionează accesul extern la servicii din cluster. Este ca un “front door” pentru trafic HTTP/HTTPS.

```
apiVersion: networking.k8s.io/v1
kind: Ingress
```
* E un Ingress modern (versiunea actuală networking.k8s.io/v1).


```
metadata:
  name: cloud-app-ingress
  annotations:
    traefik.ingress.kubernetes.io/router.entrypoints: web
```
* name: numele Ingress-ului (cloud-app-ingress).

* annotations: traefik.ingress.kubernetes.io/router.entrypoints: web – spune că Traefik (un ingress controller popular) va folosi entrypoint-ul web (de obicei portul 80, HTTP).

```
spec:
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: cloud-app-service
            port:
              number: 80
```
Această secțiune stabilește regulile de rutare:

* paths:

path: / – orice URL (ex. /, /login, /api, etc.).

pathType: Prefix – orice URL care începe cu / va fi direcționat la backend.

* backend:

service.name: cloud-app-service – Ingress va direcționa cererile către un Service numit cloud-app-service.

service.port.number: 80 – va folosi portul 80 expus de acel Service.

Rezumat:

1. Internet (ex: https://mydomain.com)
      │
      ▼
2. Ingress (cloud-app-ingress)
      │
      ▼
3. Service (cloud-app-service:80)
      │
      ▼
4. Pods (cu app: cloud-app)

E nevoie de un Ingress Controller (ex. Traefik, Nginx, etc.) instalat în cluster.


### ```load-generator.yaml```

* Creează un Pod cu un container BusyBox care rulează un script infinit:

```
while true; do wget -q -O- http://cloud-app.default.svc.cluster.local:8080/; done
```

* Trimite constant cereri HTTP (wget) către aplicația cloud-app din namespace-ul default.

* Este un fel de simulator de trafic – forțează aplicația să consume CPU și memorie.

* Scop - Să declanșeze autoscaling-ul (HPA) pentru cloud-app ca să vedem cum se scalează.

* Controlul numărului de replici
```
minReplicas: 1
maxReplicas: 5
```
* Va avea între 1 și 5 Pod-uri în funcție de load.

* Metrică de scalare
```
metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
```
* Metrica urmărită este CPU.
* Dacă CPU-ul mediu pe Pod-uri depășește 50% (averageUtilization: 50), HPA va crea Pod-uri suplimentare (până la 5).
* Dacă load-ul scade, va reduce la minim (1 Pod).


Rezumat:
[load-generator Pod]  --- cereri HTTP --->  [Deployment cloud-app (1-5 Pods)]
                                            ▲
                                   [HPA monitorizează CPU-ul]


### Cum lucrează împreună load-generator.yaml + ingress.yaml?
1. Podul load-generator bombardează cloud-app cu cereri → crește consumul CPU.
2. HPA vede că media CPU e >50% → scalează cloud-app la 2, 3, 4, 5 replici.
3. Dacă load-ul scade, HPA va reduce replicile înapoi la 1.





```
kubectl get deployment cloud-app -o=jsonpath="{.spec.template.spec.containers[*].image}"

kubectl rollout history deployment/cloud-app

kubectl rollout undo deployment/cloud-app --to-revision=65

ubectl get deployment cloud-app -o=jsonpath="{.spec.template.spec.containers[*].image}"
```