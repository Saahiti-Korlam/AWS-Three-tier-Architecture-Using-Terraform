# AWS-Three-tier-Architecture-Using-Terraform
Provisioned a secure 3-tier AWS architecture (EC2, RDS MySQL, load balancers, VPC) using Terraform with Nginx and Node.js for full-stack web serving.

Overview
In this architecture, we have three main layers:

Web Tier: Handles client requests and serves the front-end website.
Application Tier: Processes API requests and handles the business logic.
Database Tier: Manages data storage and retrieval.

Blue-print of the 3 tier architecture :
<img width="1282" height="818" alt="3-tier" src="https://github.com/user-attachments/assets/893ba3a4-6788-42a4-bda7-78d1fb50c2cc" />

Lets see what all components used here and its detailed overview:
1. External Load Balancer (Public-Facing Application Load Balancer)
Role: This acts as the entry point for all client traffic.
Functionality:
Distributes incoming client requests to the web tier EC2 instances.
Ensures even distribution of traffic for better performance and reliability.
Performs health checks to ensure only healthy instances receive traffic.

2. Web Tier
Role: Serves the front-end of the application and redirects API calls.
Components:
Nginx Webservers: Running on EC2 instances.
React.js Website: The front-end application served by Nginx.
Functionality:
Serving the Website: Nginx serves the static files for the React.js application to the clients.
Redirecting API Calls: Nginx is configured to route API requests to the internal-facing load balancer of the application tier.

3. Internal Load Balancer (Application Tier Load Balancer)
Role: Manages traffic between the web tier and the application tier.
Functionality:
Receives API requests from the web tier.
Distributes these requests to the appropriate EC2 instances in the application tier.
Ensures high availability and load balancing within the application tier.

4. Application Tier
Role: Handles the application logic and processes API requests.
Components:
Node.js Application: Running on EC2 instances.
Functionality:
Processing Requests: The Node.js application receives API requests, performs necessary computations or data manipulations.
Database Interaction: Interacts with the Aurora MySQL database to fetch or update data.
Returning Responses: Sends the processed data back to the web tier via the internal load balancer.

5. Database Tier (Aurora MySQL Multi-AZ Database)
Role: Provides reliable and scalable data storage.
Functionality:
Data Storage: Stores all the application data in a structured format.
Multi-AZ Setup: Ensures high availability and fault tolerance by replicating data across multiple availability zones.
Data Retrieval and Manipulation: Handles queries and transactions from the application tier to manage the data.

## Additional Components

### Load Balancing
- Distributes incoming traffic evenly across multiple instances to prevent any single instance from becoming a bottleneck
- **Web Tier:** External load balancer routes traffic across web server instances
- **Application Tier:** Internal load balancer distributes API requests across application server instances

### Health Checks
- Continuously monitors instance health to ensure only healthy instances receive traffic
- **Web Tier:** External load balancer performs health checks to verify web servers are responsive
- **Application Tier:** Internal load balancer monitors application servers to confirm they are operational

### Auto Scaling Groups
- Automatically adjusts the number of running instances based on traffic load to maintain performance and cost efficiency
- **Web Tier:** Scales web server instances in or out based on metrics like CPU usage or request count
- **Application Tier:** Scales application server instances using similar metrics to match demand

Summary
This architecture ensures high availability, scalability, and reliability by distributing the load, monitoring instance health, and scaling resources dynamically. The web tier serves the front-end and routes API calls, the application tier handles business logic and interacts with the database, and the database tier provides robust data storage and retrieval.
