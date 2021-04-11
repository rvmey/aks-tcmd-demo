export TOKEN=$(cat ~/.TRIGGERcmdData/token.tkn)
echo $TOKEN

export AKS_DEMO_COMPUTER="AKS_DEMO"

export COMPUTER_ID=$(curl -H "Authorization: Bearer ${TOKEN}" https://www.triggercmd.com/api/computer/save?name=${AKS_DEMO_COMPUTER} | jq -r .data.id)

echo ${COMPUTER_ID}