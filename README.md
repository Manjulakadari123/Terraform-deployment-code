Infrastructure-as-Code Deployment Documentation

🧾 Project Overview
This project provisions a secure  AWS architecture using Terraform. It includes:
•	Custom VPC with public and private subnets 
•	API EC2 instance in public subnet 
•	Worker EC2 instances in private subnet 
•	Security groups controlling SSH and application traffic 
•	RPC communication between API and workers using port 5000 

Architecture:
                                      User / Client
                                           |
                                           |  HTTP (JSON request)
                                           v
                                 API Server (Public EC2)
                                           |
                                           |  Internal call (RPC / private IP)
                                           v
                               Worker Server (Private EC2)
                                           |
                                           |  Process data
                                           v
                                       API Server
                                           |
                                           |  JSON Response
                                           v
                                          User
Terraform Deployment:
  Terraform plan:

 <img width="940" height="529" alt="image" src="https://github.com/user-attachments/assets/6a43726b-dd29-40f1-817e-a771f2414478" />


Terraform apply:

 <img width="940" height="529" alt="image" src="https://github.com/user-attachments/assets/dc1dda32-28a1-4d19-8eae-0b420c1b3f14" />


Infrastructure Components:
      1. VPC
•	CIDR: 10.0.0.0/16 
•	Provides isolated network environment

 <img width="940" height="529" alt="image" src="https://github.com/user-attachments/assets/aee9ada8-6962-4d10-9010-313e074f57a3" />


2. Subnets
•	Public Subnet 
o	Hosts API server 
•	Private Subnet 
o	Hosts worker nodes

 <img width="940" height="529" alt="image" src="https://github.com/user-attachments/assets/f4e3a4dd-8573-4257-8bd5-dfcd791af828" />


3. EC2 Instances
API Server
•	Publicly accessible 
•	Handles incoming HTTP requests 
Worker Nodes
•	Located in private subnet 
•	Not directly accessible from internet 
•	Accept requests only from API security group

 <img width="940" height="529" alt="image" src="https://github.com/user-attachments/assets/912bc15f-625f-46c0-b303-81da515e9d65" />


4. Security Groups
🔐 API Security Group
•	SSH → Port 22 (restricted to your IP) 
•	HTTP → Port 80 (open to internet) 
•	HTTPS → Port 443 (open to internet)

 <img width="940" height="529" alt="image" src="https://github.com/user-attachments/assets/e97ba5a7-8c3c-4b21-84a0-acc3b8d40765" />


Worker Security Group
•	SSH → Port 22 (restricted to your IP) 
•	Application → Port 5000 (only from API security group)

 <img width="940" height="529" alt="image" src="https://github.com/user-attachments/assets/19df0802-604b-4933-bccf-2bdae8144425" />


Worker Node Configuration

•	Both worker nodes contain:
•	Python installed 
•	RPC application running 
•	Port 5000 enabled internally 

Installation commands:
sudo apt update
sudo apt install python3 python3-pip -y
pip3 install flask

Run worker application:
python3 worker.py

RPC Communication Flow
1.	Client sends request to API server 
2.	API server forwards request to worker nodes 
3.	Worker node processes request 
4.	Worker returns response 
5.	API server returns JSON response to client
   
API Test Command:
      curl -X POST http://<API-PUBLIC-IP>:5000/predict \
      -H "Content-Type: application/json" \
     -d '{"data":[1,2,3,4]}'
     
Sample Response:
    {
  "prediction": 42
}


