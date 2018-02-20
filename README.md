# ProjectSpawntck
Project to Spawn a titanium crucible Installation with Cloud Foundry and Kubernetes

*Credits to komljen for the kubernetes yaml files for deploying ELK*

# ProjectSpawnSwarmtck
Project to Spawn a titanium crucible (receiver + multiple honeypots) installation in an automated way across different Clouds (AWS and optionally GCE) using Docker containers, Kubernetes, Cloud Foundry and basic Service Discovery. 
An ELK stack gets started in Kubernetes (GKE), honeypot instances are started in Cloud Foundry (Pivotal Web services). Some local docker containers perform Service discovery and mapping for the different application components.

A dockerized etcd instances is used to store variables/application parameters in a KV store.
The code stores all application information in etcd and uses the data stored to scale up, scale down, perform a basic TDD/CI and eventually tear down the application.

Tested on a t1.micro AMI

To install the prerequisites on an AMI image use this piece of code:

https://github.com/FabioChiodini/AWSDockermachine

[the script is run in the context of ec2-user account]

>>> Install kubectl

### How to launch

Launch the main script with no parameters (all parameters are stored in the configuration file **Cloud1)

```

./GKE.sh

```

## Configuration Files
To run this script you have to prepare two configuration files (in /home/ec2-user)
- **Cloud1** see below for syntax




## Script Flow 

This script performs these tasks (leveraging Docker-Machine):


- Loads config files
- Prepares etcd and other infrastructure services starting docker containers locally
- Starts Kubernetes cluster
- Logs Kubernetes cluster variables in etcd
- Executes ELK on Kubernetes
- Logs ELK variables in etcd
- Launch honeypots



Here's an high level diagram: 

![Alt text](/images/Main.png "Main")

## Environment Variables

The code uses a file to load the variables needed (/home/ec2-user/Cloud1).

This file has the following format:

```
export K1_AWS_ACCESS_KEY=AKXXXXXX

export K1_AWS_SECRET_KEY=LXXXXXXXXXX

export K1_AWS_VPC_ID=vpc-XXXXXX

export K1_AWS_ZONE=b

export K1_AWS_DEFAULT_REGION=us-east-1

export AWS_DEFAULT_REGION=us-east-1

export VM_InstancesK=2
export Container_InstancesK=3

export GCEKProvision=1

export GCEVM_InstancesK=1


export ReceiverPortK=61116
export ReceiverImageK=kiodo/receiver:latest
export HoneypotPortK=8080
export HoneypotImageK=kiodo/honeypot:latest

export ConsulDynDNSK=1
export DynDNSK=XXXX2.ddns.net

export etcdbrowserprovision=0

export instidk=2
```

Here are the details on how these variables are used:

- The first five variable are used by the docker-machine command and are related to your AWS account

- **AWS_DEFAULT_REGION** variable is used by AWS cli (to edit the security group) 

- **VM_InstancesK** is used to determine the number of VM that will be spawned on AWS 
- **Container_InstancesK** is used to state how many Containers instances will be run

- **GCEKProvision** is a flag to enable provisioning on GCE
- **GCEVM_InstancesK** is used to determine the number of VM that will be spawned on GCE

- **K2_GOOGLE_AUTH_EMAIL** contains the google account email for your GCE project (shown in the manage service accounts panel, this is NOT your google email :P)

- **K2_GOOGLE_PROJECT** contains the project to targte for GCE

- **GOOGLE_APPLICATION_CREDENTIALS** maps to a file containing the Service account keys for your GCE login

- **ReceiverPortK** and **ReceiverImageK** are the port used and the docker image for the receiver Application

- **HoneypotPortK** and **HoneypotImageK** are the port used and the docker image for the honeypot Applications to launch via Docker swarm

- **ConsulDynDNSK** is a flag to determine if the Consul Dockerized instance will be launched locally (to eventually leveragge a local dyndns setup

- **DynDNSK** contains the dyndns name used for the host where this code is launched (ie where the Consul instance will be executed if ConsulDynDNSK=1)

- **etcdbrowserprovision** is a flag to determine if an etcd-browser containerized instance will be launched in GCE 

- **instidk** is a string (that will be added as a prefix to all names of items created) to allow for multiple deployment of tc in the same AWS and GCE instances (avoiding duplicate names)  (**you MUST use lowercase string due to GCE docker machine command line limitations**)



![Alt text](/images/Cloud1.png "Cloud1")

The code also uses another file: GCEkeyfile.json 
- This contains data that is used for GCE authentication (Service account keys type in JSON format)


## Kubernetes Configuration Files
Yaml files for the Kubernetes deployment are located in /kubefiles

These files start an ELK application deployed in multiple containers and publish it over the internet on a GKE cluster.


## Service Discovery

For demo purposes two service discovery services are used: Consul and etcd

All the items created by the code are registered in the KV store of **etcd** to allow for further manipulation.



### etcd
etcd is launched as a local dockerized applications and stores variables that are used in the main Spawn, in the scale up and tear down code

**jq** is installed on the local AMI (automatically during Spawn execution) to manipulate JSON files in shell scripts

#### etcd-browser

An application (etcd-browser) has been added for showing in a web GUI the data that gets stored to etcd:

![Alt text](/images/etcd-browser.png "etcd-browser")

To enable the use of this application it is necessary to **manually** open port 4001 on the VM where the main script is launched. App port (8000) for etcd-browser is opened up automatically (if the etcd-browser is launched on a remote host.


![Alt text](/images/Port4001.png "Port4001")

**Added value**: The etcd broswer is also useful for testing this code as you can change values inside etcd directly from its web interface


## NOTES ON Spawning to GCE

To spawn VMs to GCE you need to **Install the GCE SDK** on your AMI image (install and configure the SDK in the context of the ec2-user user):
- curl https://sdk.cloud.google.com | bash
- exec -l $SHELL
- gcloud init (this will start an interactive setup/configuration)


You also need to properly set up your GCE account, following are the high level steps:

- Enable the Compute Engine API

- Create credentials (Service account keys type - JSON format) and download the json file to /home/ec2-user/GCEkeyfile.json

- Enable billing for your account

Then you need to perform these configurations in the /home/ec2-user/Cloud1 file:

- Populate the configuration file with your GCE account details
- Enable the flag to provision to GCE
- Indicate a number of VMs to provision to GCE

Finally activate your service account by issuing this command:

```
gcloud auth activate-service-account --key-file /home/ec2-user/GCEkeyfile.json
```

## Scale Out Code
TBI
Leetha.sh is the code that automates the scale out of the setup after the first deployment

It reads configuration information from the etcd local instances (to connect to swarm, set up docker-machine and to launch honeypots).

It then launches a number of Docker VMs and honeypot containers as specified with the following launch parameters

### How to launch
TBI
```

./Leetha.sh instancestoaddAWS instancestoaddGCE HoneypotsToSpawn 

```
During the launch it also respawns Honeypots containers that were already started in previous runs as these are ephemeral workloads (Still TBI, now it just adds containers specified in launch parameters)

Added value (:P) : If launched without parameters the code opens up all firewall port needed by the application


## Scale Down Code
TBI
Redeemer.sh is the code that automates the scale down of the setup after the first deployment

It reads configuration information from the etcd local instances (to connect to swarm, set up docker-machine, gets the number of Docker machines and honeypots and to restart honeypots).

It then destroys the specified Docker machine instances in GCE or AWS. It also cleans up the relevant registrations in etcd and Consul (Consul TBI).

It then restarts honeypot containers to match the number specified with the following launch parameters

### How to launch

```

./Redeemer.sh instancestoremoveinAWS instancestoremoveinGCE HoneypotsToremove 

```
During the launch it also respawns Honeypots containers that were already started in previous runs as these are ephemeral workloads.

This code does NOT reopen firewall ports in GCE or AWs.


## Tear Down Code

Malebolgia.sh is the code that automates the environment teardown

It reads configuration information from the etcd local instances (to connect to swarm, set up docker-machine and to launch honeypots).

It then destroys:
- Pods provisioned on Kubernetes
- Remote Kubernetes Cluster
- Infrastructure Components (etcd-browser)
- Local Docker instances (etcd if local)



###How to launch

```
./Malebolgia.sh
```

## Continuous Integration Code
TBI
[This is more like Test Driven Deployment (TDD) :P ]

This code is meant to help in testing the elements deployed by the main code and validate that any change to the base code has been successful

The code tests these components:
- Data written in etcd
- Honeypots
- Receiver Instance


After getting the setup details from etcd it tests if the ports are open for the components listed and basically test the Honeypots application (parsing a curl output).

### How to launch:

```
./CISpawntc
```

The results of the tests are written in etcd:

![Alt text](/images/CICD.png "CICD")

Running these tests multiple times updates the test flags value in etcd.



# Minimal Launch Instructions

Following are high level notes on how to get this running quickly:

- Start a t1.small on AWS

- Open ports for this VM on AWS
 - 22 (to reach it ;) )
 - 4001 (all IPs) for etcd-browser
 - 8500 (all IPs) for etcd

![Alt text](/images/MainInboundRules.png "MainInboundRules")

- Connect via SSH to your AWS instance (ie in my case: Get PuTTy configured with AWS key :P )

- Run AWSDockermachine code

- Populate /home/ec2-user/Cloud1

- Populate /home/ec2-user/GCE JSON (if using GCE)

- Validate GCE account [ gcloud auth activate-service-account --key-file /home/ec2-user/GCEkeyfile.json ]

- git clone this code : https://github.com/FabioChiodini/ProjectSpawnSwarmtck.git

- Launch script


@FabioChiodini




