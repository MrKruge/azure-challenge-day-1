# Cloud Club Azure Challenge 1 – Broken Web Server 🚀

Welcome to **The Cloud Club**!  
Here, we learn by doing — not watching tutorials — by debugging broken cloud infrastructure.

This is your first Azure challenge. It's a warm-up to show you how our challenges work.

---

---

## 📖 Scenario

A startup developer deployed a simple web server in Azure:

- Ubuntu VM
- NGINX installed
- Public IP
- Virtual Network + Subnet
- Network Security Group (NSG)

But something is wrong. **The web server is not reachable from the internet.**

**Your mission:** figure out what's wrong, fix it, and validate your fix.

---

---

## ⚠️ Problem

When accessing the web server via the VM's public IP:

```bash
curl http://<PUBLIC_IP>
```

The connection **times out**.

✅ **Expected behavior:** You should see a simple HTML page:

```html
<h1>Cloud Club Azure Challenge</h1>
```

---

---

## 🧑‍💻 Deployment Instructions

### Step 1: Open Azure Cloud Shell

1. Go to the [Azure Portal](https://portal.azure.com)
2. Click the **Cloud Shell** icon (top-right)
3. Select **Bash** or **PowerShell**

### Step 2: Deploy the Infrastructure

Deploy using subscription-level deployment:

```bash
az deployment sub create \
  --location westeurope \
  --template-file day-1-challenge.bicep \
  --parameters adminPassword='P@ssw0rd1234!'
```

Wait until deployment completes.

---

---

## 🕵️ Step 3: Investigate

Check the following Azure resources:

- Virtual Network (VNet)
- Subnet
- Network Security Group (NSG)
- Network Interface (NIC)
- Virtual Machine

💡 **Hint:** Think about how traffic flows from the internet to a VM in Azure.  
What controls inbound traffic?

---

---

## 🔧 Step 4: Fix It

The problem is intentional: **NSG does not allow HTTP (port 80).**

### Fix it via the Azure Portal:

1. Go to **Network Security Groups** → `challenge-nsg` → **Inbound security rules**
2. Add a rule allowing:
   - **Source:** Any
   - **Destination:** Any
   - **Protocol:** TCP
   - **Port:** 80
   - **Action:** Allow
3. Save and retry accessing the web server

### Or fix it via Azure CLI:

```bash
az network nsg rule create \
  --resource-group CloudClub-Challenge1-RG \
  --nsg-name challenge-nsg \
  --name Allow-HTTP \
  --priority 1010 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp \
  --destination-port-ranges 80
```

---

---

## ✅ Step 5: Validate

Test the web server:

```bash
curl http://$(az vm show -d -g CloudClub-Challenge1-RG -n challenge-vm --query publicIps -o tsv)
```

✅ **Success:** The HTML page appears. Challenge solved!

---

## 🧹 Step 6: Clean Up

Delete the resource group to avoid charges:

```bash
az group delete --name CloudClub-Challenge1-RG --yes --no-wait
```

---

## 📚 What You Learned

- How to deploy Azure infrastructure using Bicep
- Understanding Network Security Groups (NSGs)
- Troubleshooting network connectivity issues
- How inbound traffic rules control VM access

---

## 🎉 Next Steps

Ready for more challenges? Check out the next challenge in this series!

**Happy Learning!** 🚀
