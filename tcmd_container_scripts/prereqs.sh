apt-get update -y && apt install curl -y
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl"
chmod +x /usr/local/bin/kubectl
