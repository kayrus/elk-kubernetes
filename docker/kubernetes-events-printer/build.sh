IMG=kayrus/kubernetes-events-printer:latest
docker build -t $IMG .
docker push $IMG
