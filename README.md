# grass_linux_python

**Run your Grass mining as a service in just a few seconds!**

## **Description**

This project allows you to run your Grass mining script as a **system service** on Linux. It sets up the necessary environment and ensures that the mining process runs continuously in the background, even after reboots.

## **Prerequisites**

- **A Linux system** (Debian/Ubuntu recommended)
- **Python 3 installed** (the script will install it if not present)
- **An active [Grass](https://app.getgrass.io/register/?referralCode=6VFixd3LUhIScVp)** account

## **Installation**

Follow these simple steps to set up the service:

### **1. Get Your User ID**

1. **Log in** to your Grass account at [https://app.getgrass.io/dashboard](https://app.getgrass.io/dashboard).
2. **Open the browser console**:
   - **Chrome**: Right-click anywhere on the page, select **Inspect**, and then go to the **Console** tab.
   - **Firefox**: Right-click anywhere on the page, select **Inspect Element**, and then go to the **Console** tab.
3. **Retrieve your User ID**:
   - In the console, type the following command and press **Enter**:
     ```javascript
     localStorage.getItem('userId')
     ```
   - **Copy** the returned **User ID**.

![Get User ID](https://github.com/user-attachments/assets/0f260cbd-a5ce-4cf0-b5fd-87a10f972eed)

### **2. Update the `grassdeploy.sh` Script**

1. **Download** the `grassdeploy.sh` script to your Linux system.
2. **Open** the script in a text editor of your choice.
3. **Locate** the following line:
   ```bash
   _user_id = '89f963fc-f72f-4a00-af43-cbb151c5a587'  # Replace with your user ID

   ## **Referral**

----------------------------------------------

🎉 **Earn 5000 Points by Registering with My Referral Link!** 🎉

Support this project and receive **5000 points** by signing up through my referral link:

👉 [**Register with Grass and Get 5000 Points!**](https://app.getgrass.io/register/?referralCode=6VFixd3LUhIScVp)

**Don't miss out on this opportunity!**

