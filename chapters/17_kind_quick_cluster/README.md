# Chapter 17 — kind 빠른 K8s 클러스터 생성/삭제 (WSL2 + Docker 기반)

## 목표
WSL2에서 **Docker 기반으로 Kubernetes 클러스터를 “빠르게 만들고/부수는”** 실습을 합니다.

- kind 클러스터 생성(단일 control-plane)
- kubectl로 노드/시스템 파드 확인
- (옵션) 샘플 nginx Pod 띄우고 port-forward로 접속
- 클러스터 삭제(깨끗한 정리)

> 이 챕터는 WSL2에 Kubernetes를 “정식 설치(k3s/kubeadm)” 하지 않고도
> **실무형 K8s 리소스 흐름을 빠르게 연습**할 때 유용합니다.

## 전제
- Docker Desktop (WSL integration ON)
- `kind`, `kubectl` 설치 필요

### 설치 힌트(인터넷 필요)
```bash
# kubectl (Linux)
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm -f kubectl

# kind
curl -Lo kind https://kind.sigs.k8s.io/dl/v0.23.0/kind-linux-amd64
chmod +x kind
sudo mv kind /usr/local/bin/kind
```

## 실행
- 클러스터 생성:
  ```bash
  ./run.sh
  ```
- 클러스터 삭제:
  ```bash
  ./destroy.sh
  ```

## 다음 단계(추천)
- Harbor 이미지를 kind에서 pull하는 실습: Chapter 08
