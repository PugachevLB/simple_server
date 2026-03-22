# simple_server

helm upgrade --install myapp ./typicalapp -f typicalapp/values.yaml --kube-apiserver https://172.16.0.25:16443 --namespace default --atomic --timeout 3m

helm ls --kube-apiserver https://172.16.0.25:16443 --namespace default

export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=typicalapp,app.kubernetes.io/instance=myapp" -o jsonpath="{.items[0].metadata.name}")
export CONTAINER_PORT=$(kubectl get pod --namespace default $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
export SVC_NAME=$(kubectl get svc --namespace default -l "app.kubernetes.io/name=typicalapp,app.kubernetes.io/instance=myapp" -o jsonpath="{.items[0].metadata.name}")


microk8s.kubectl port-forward -n default pod/$POD_NAME 16555:$CONTAINER_PORT --address 0.0.0.0
microk8s.kubectl port-forward -n default svc/$SVC_NAME 16555:$CONTAINER_PORT --address 0.0.0.0