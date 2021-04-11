# Create a Azure Kubernetes cluster
az group create --location eastus --resource-group russ-aks
az aks create --resource-group russ-aks --name demo-cluster --node-count 1
az aks get-credentials --name demo-cluster --resource-group russ-aks

# Get your TRIGGERcmd token
export TOKEN=$(cat ~/.TRIGGERcmdData/token.tkn)

# Create a computer object in the TRIGGERcmd account for the container running in Kubernetes
export COMPUTER_NAME="AKS_Demo_Container"
export COMPUTER_ID=$(curl -H "Authorization: Bearer ${TOKEN}" "https://www.triggercmd.com/api/computer/save?name=${COMPUTER_NAME}&voice=container" | jq -r .data.id)

# Create a secret containing the token and the computer ID.  
kubectl delete secret generic tcmd-secret > /dev/null 2>&1
kubectl create secret generic tcmd-secret --from-literal=token=${TOKEN} --from-literal=computerid=${COMPUTER_ID}

# Create a configmap with the commands you can run on the container via TRIGGERcmd
kubectl delete configmap commands-config > /dev/null 2>&1
kubectl create configmap commands-config --from-literal=commands='
[
    {
        "trigger": "Install Prereqs",
        "command": "wget -O - https://raw.githubusercontent.com/rvmey/aks-tcmd-demo/master/tcmd_container_scripts/prereqs.sh | bash",
        "ground": "foreground"
    }, 
    {
        "trigger": "Run nginx",
        "command": "kubectl run nginx --image=nginx",
        "offCommand": "kubectl delete po nginx",
        "ground": "foreground",
        "voice": "engine x",
        "allowParams": "true"
    }
]'

# Create the tcmd deployment
kubectl delete deploy tcmd-deployment > /dev/null 2>&1
kubectl apply -f ./kubernetes_manifests

# Watch for the creation of the Nginx pod
watch kubectl get po