Medi-Ledger Smart Contract

Medi-Ledger is a Clarity-based smart contract designed to securely store, manage, and share medical records on the Stacks blockchain.  
It empowers **patients** with control over their health data while allowing **authorized providers** to access records in a transparent and trustless way.

---

Features
- **Patient Registry** – Register patients with unique identifiers.  
- **Provider Access** – Register verified healthcare providers.  
- **Secure Records** – Store encrypted medical data with immutable references.  
- **Access Control** – Patients can grant or revoke access to their records.  
- **Audit Trail** – Immutable history of record creation and updates.  

---

Project Structure
-contracts
-medi-ledger.clar 
-Core smart contract
-tests
-medi-ledger test.ts 
-Example test cases


---

Deployment
1. Install [Clarinet](https://github.com/hirosystems/clarinet).  
2. Clone this repository:
   ```bash
   git clone https://github.com/your-username/medi-ledger.git
   cd medi-ledger
