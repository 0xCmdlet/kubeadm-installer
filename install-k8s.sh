#!/usr/bin/env bash
set -euo pipefail

# Simple Kubernetes installation script for Debian/Ubuntu

K8S_VERSION_STREAM="v1.34"
KEYRING_DIR="/etc/apt/keyrings"
KEYRING_FILE="${KEYRING_DIR}/kubernetes-apt-keyring.gpg"
LIST_FILE="/etc/apt/sources.list.d/kubernetes.list"

echo "[1/5] Updating package index..."
sudo apt-get update -y

echo "[2/5] Installing prerequisites..."
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

echo "[3/5] Setting up Kubernetes APT keyring..."
# Ensure keyring dir exists
if [ ! -d "${KEYRING_DIR}" ]; then
  sudo mkdir -p -m 755 "${KEYRING_DIR}"
fi

# Fetch and install the key
curl -fsSL "https://pkgs.k8s.io/core:/stable:/${K8S_VERSION_STREAM}/deb/Release.key" \
  | sudo gpg --dearmor -o "${KEYRING_FILE}"

echo "[4/5] Configuring Kubernetes APT repo..."
# This overwrites any existing kubernetes.list
echo "deb [signed-by=${KEYRING_FILE}] https://pkgs.k8s.io/core:/stable:/${K8S_VERSION_STREAM}/deb/ /" \
  | sudo tee "${LIST_FILE}" > /dev/null

echo "[5/5] Installing kubelet, kubeadm, kubectl..."
sudo apt-get update -y
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

echo "✅ Kubernetes components installed and held:"
kubeadm version && kubectl version --client && kubelet --version || true
