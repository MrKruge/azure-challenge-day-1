Cloud Club Azure Challenge 1 – Broken Web Server 🚀

Welcome to The Cloud Club!
Here, we learn by doing — not watching tutorials — by debugging broken cloud infrastructure.

This is your first Azure challenge. It’s a warm-up to show you how our challenges work.

📖 Scenario

A startup developer deployed a simple web server in Azure:

Ubuntu VM

NGINX installed

Public IP

Virtual Network + Subnet

Network Security Group (NSG)

But something is wrong. The web server is not reachable from the internet.

Your mission: figure out what’s wrong, fix it, and validate your fix.

⚠️ Problem

When accessing the web server via the VM’s public IP:

curl http://<PUBLIC_IP>


The connection times out.

✅ Expected behavior: You should see a simple HTML page:

Cloud Club Azure Challenge

🧑‍💻 Deployment Instructions
Step 1: Open Azure Cloud Shell

Go to the Azure Portal

Click the Cloud Shell icon (top-right)

Select Bash or PowerShell

Step 2: Create a Resource Group
az group create --name CloudTalents-Challenge1 --location westeurope

Step 3: Deploy the Broken Infrastructure

Copy the challenge.bicep file into Cloud Shell, then run:

az deployment group create \
  --resource-group CloudTalents-Challenge1 \
  --template-file challenge.bicep \
  --parameters adminPassword='P@ssw0rd1234!'


Wait until deployment completes.

🕵️ Step 4: Investigate

Check the following Azure resources:

Virtual Network (VNet)

Subnet

Network Security Group (NSG)

Network Interface (NIC)

Virtual Machine

💡 Hint: Think about how traffic flows from the internet to a VM in Azure.
What controls inbound traffic?

Step 5: Fix It

The problem is intentional: NSG does not allow HTTP (port 80).

Fix it via the Azure Portal:

Go to Network Security Groups → challenge-nsg → Inbound security rules

Add a rule allowing:

Source: Any

Destination: Any

Protocol: TCP

Port: 80

Action: Allow

Save and retry accessing the web server.

Step 6: Validate
curl http://$(az vm show -d -g CloudTalents-Challenge1 -n challenge-vm --query publicIps -o tsv)


✅ Success: The HTML page appears. Challenge solved!

Step 7: Clean Up
az group delete --name CloudTalents-Challenge1 --yes --no-waitcd# azure-challenge-day-1
