## Jenkins

Get  username and password to connect to Jenkins:
kubectl --namespace jenkins get secret jenkins-operator-credentials-jenkins -o 'jsonpath={.data.user}' | base64 -d
kubectl --namespace jenkins get secret jenkins-operator-credentials-jenkins -o 'jsonpath={.data.password}' | base64 -d


create a VM for our bastionand use the Azure Bastion Host to securely ssh into the VMs.

To get the kubeconfig, you can do an az login and az aks get-credentials . Check the docs for more information. The below gist explains the steps to check the connection inside the VM after logging in through the Azure Bastion.

**Plugins**
git for source control
Azure Credentials plugin for connecting securely
Azure VM Agents plugin for elastic build, test and continuous integration
Azure Storage plugin for storing artifacts
Azure CLI to deploy apps using scripts


Azure Disk storage class
storageaccounttype: Azure storage account Sku tier. Default is empty.
kind: Possible values are shared (default), dedicated, and managed. When kind is shared, all unmanaged disks are created in a few shared storage accounts in the same resource group as the cluster. When kind is dedicated, a new dedicated storage account will be created for the new unmanaged disk in the same resource group as the cluster. When kind is managed, all managed disks are created in the same resource group as the cluster.
resourceGroup: Specify the resource group in which the Azure disk will be created. It must be an existing resource group name. If it is unspecified, the disk will be placed in the same resource group as the current Kubernetes cluster.
Premium VM can attach both Standard_LRS and Premium_LRS disks, while Standard VM can only attach Standard_LRS disks.
Managed VM can only attach managed disks and unmanaged VM can only attach unmanaged disks.
