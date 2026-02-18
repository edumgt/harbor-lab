# Chapter 08 — (옵션) kind(Kubernetes in Docker)에서 Harbor 이미지 pull 테스트

## 목표
- 로컬 kind 클러스터를 만들고
- Harbor registry에서 이미지를 pull하여 Pod를 실행해봅니다.

## 전제
- Docker Desktop이 CA를 신뢰해야 함(Chapter 03)
- kind 설치 필요: https://kind.sigs.k8s.io (사용자 설치)
- kubectl 설치 필요

---
```
kubectl config get-contexts
kubectl config use-context kind-harbor-lab
kubectl config current-context
```
---
```
echo "KUBECONFIG=$KUBECONFIG"
echo "HOME=$HOME"
ls -al ~/.kube || true
ls -al ~/.kube/config || true
kubectl config view --minify
```
---
```
root@DESKTOP-D6A344Q:/home/Harbor-wsl2-lab# cp -a /root/.kube/config /root/.kube/config.bak.$(date +%Y%m%d-%H%M%S)
root@DESKTOP-D6A344Q:/home/Harbor-wsl2-lab# kind export kubeconfig --name harbor-lab --kubeconfig /root/.kube/config
Set kubectl context to "kind-harbor-lab"
root@DESKTOP-D6A344Q:/home/Harbor-wsl2-lab# kind get kubeconfig --name harbor-lab > /root/.kube/config
chmod 600 /root/.kube/config
```
---
```
kind get clusters
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep kind-harbor-lab || true
```

## 실행
```bash
./run.sh
```

> 이 챕터는 “K8s 배포 관점”을 빠르게 체감하기 위한 옵션입니다.


## 참고(HTTPS self-signed Harbor)
- Harbor가 HTTPS(self-signed CA)인 경우, kind 노드에 CA 주입이 필요합니다. (Chapter 18 참고)
