#!/bin/bash -x
function run_server()
{
  kubectl run pod1 --image=networkstatic/iperf3 --overrides="{\"spec\": { \"nodeSelector\": {\"kubernetes.io/hostname\": \"$1\"}}}" --command -- iperf3 -4 -s 
}

function run_client()
{
  ipq=$(kubectl get pods pod1 -o json|jq ".status.podIP")
  ipq1=${ipq#\"}
  ip=${ipq1%\"}
  cat >client-job.yaml <<EOF
apiVersion: batch/v1
kind: Job
metadata:
  name: iperf3-client
spec:
  template:
    spec:
      containers:
      - name: iperf3-client
        image: networkstatic/iperf3
        command: ["iperf3", "-4", "-c", "$ip", "-t", "10"]
      nodeName: $1
      restartPolicy: Never
  backoffLimit: 4
EOF
  kubectl apply -f client-job.yaml
  client_pod=$(kubectl get pods --selector=job-name=iperf3-client --output=jsonpath='{.items[*].metadata.name}')
}

function hostip_of()
{
  hostipq=$(kubectl get pods $1 -o json|jq ".status.hostIP")
  hostipq1=${hostipq#\"}
  hostip=${hostipq1%\"}
  echo $hostip
}

function uid_of()
{
  uidq=$(kubectl get pods $1 -o json|jq ".metadata.uid")
  uidq1=${uidq#\"}
  uid=${uidq1%\"}
  echo $uid
}

function data_of()
{
  tail -n 1 $1 |
	  awk '{if ( $8 == "Mbits/sec") print $7*1e6*60; else if ( $8 == "Gbits/sec") print $7*1e9*60;}'
}
server_hostname=$1
client_hostname=$2
output_dir=$3
mkdir -p ${output_dir}
run_server ${server_hostname}
server_hostip=$(hostip_of pod1)
server_uid=$(uid_of pod1)
kubectl wait --for=condition=Ready pod/pod1
run_client ${client_hostname}
client_hostip=$(hostip_of ${client_pod})
client_uid=$(uid_of ${client_pod})
kubectl wait --for=condition=Ready pod/${client_pod}
sleep 20
kubectl logs pod1 >${output_dir}/server.log
kubectl logs ${client_pod} >${output_dir}/client.log
kubectl delete pod pod1
kubectl delete job iperf3-client
