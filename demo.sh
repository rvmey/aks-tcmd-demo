# Create a Azure Kubernetes cluster
az group create --location eastus --resource-group russ-aks
az aks create --resource-group russ-aks --name demo-cluster --node-count 1
az aks get-credentials --name demo-cluster --resource-group russ-aks

# Get your TRIGGERcmd token
export TOKEN=$(cat ~/.TRIGGERcmdData/token.tkn)

# Create a computer object in the TRIGGERcmd account for the container running in Kubernetes
export AKS_TCMD_COMPUTER="AKS_DEMO_CONTAINER"
export COMPUTER_ID=$(curl -H "Authorization: Bearer ${TOKEN}" https://www.triggercmd.com/api/computer/save?name=${AKS_TCMD_COMPUTER} | jq -r .data.id)

# Create a secret containing the token and the computer ID.  
kubectl create secret generic tcmd-secret --from-literal=token=${TOKEN} --from-literal=computerid=${COMPUTER_ID}

# Create a configmap with the commands you can run on the container via TRIGGERcmd
kubectl create configmap commands-config --from-literal=commands='
[
    {
        "trigger": "Install Prereqs",
        "command": "wget -O - https://raw.githubusercontent.com/rvmey/aks-tcmd-demo/master/tcmd_container_scripts/prereqs.sh | bash",
        "ground": "foreground"
    }, 
    {
        "trigger": "Run nginx",
        "command": "/kubectl run nginx --image=nginx",
        "offCommand": "/kubectl delete po nginx",
        "ground": "foreground",
        "voice": "engine x"
    }
]'

# Create the tcmd deployment
kubectl apply -f ./kubernetes_manifests