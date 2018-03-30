# ProjectSpawntck
Project to Spawn a titanium crucible Installation with Cloud Foundry and Kubernetes (*optional: can integrate with istio and deploy serverless workloads on Project riff*)

*Credits to komljen for the kubernetes yaml files for deploying ELK*

# ProjectSpawnSwarmtck
Project to Spawn a titanium crucible (receiver + multiple honeypots) installation in an automated way across different Clouds (AWS and optionally GCE) using Docker containers, Kubernetes, Cloud Foundry and basic Service Discovery. 
- An ELK stack gets started in Kubernetes (GKE)
- Honeypot instances are started in Cloud Foundry (Pivotal Web services)
- Some local docker containers perform Service discovery and mapping for the different application components
- [Optional] Istio to provide telemetry for some of the pods deployed to Kubernetes
- [Optional] Project riff to show how to deploy Functions on top of Kubernetes 

A dockerized etcd instances is used to store variables/application parameters in a KV store.
The code stores all application information in etcd and uses the data stored to scale up, scale down, perform a basic TDD/CI and eventually tear down the application.

This is a setup targeted at demonstranting the different abstactions (Container as a service, platform as a service) and Cloud native Tools (Service Discovery, KV stores) that you can use to build your new applications.

Tested on a t1.micro AMI

To install the prerequisites on an AMI image use this piece of code:

https://github.com/FabioChiodini/AWSDockermachine

[the script is run in the context of ec2-user account]

>>> Install kubectl

### How to launch

Create an instance on AWS (t1 micro, update it and install components using this script https://github.com/FabioChiodini/AWSDockermachine )
Launch the main script with no parameters (all parameters are stored in the configuration file **Cloud1)

```

./GKEProvision.sh

```
This will create a Kubernetes Cluster on GKE and connect to it. 

```

./SpawnSwarmtcK.sh

```

This will provision an ELK stack in Kubernetes and publish its services over the internet (all parameters are logged in an etcd instance)

```

./CFProvision.sh

```

This script will start honeypot instances on Cloud Foundry. Instances will be configured to log to the ELK stack previously created



## Configuration Files
To run this script you have to prepare one configuration file (in /home/ec2-user)
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

![Alt text](/images/HighLevel.png "HighLevel")

And a more detailed one:

![Alt text](/images/ProjecttcK.png "ProjecttcK")

## Environment Variables

The code uses a file to load the variables needed (/home/ec2-user/Cloud1).

This file has the following format:

```
export ReceiverPortK=61116
export ReceiverImageK=kiodo/receiver:latest
export HoneypotPortK=8080
export localhoneypot1=1
export localhoneypot2=1
export HoneypotImageK=kiodo/honeypot:latest
export HoneypotImageK2=kiodo/honeypot:latest

export etcdbrowserprovision=0

export localKuberneteshoneypotprovision=0

export ingresslogstash=0

export instidk=2
```

Here are the details on how these variables are used:

- **ReceiverPortK** and **ReceiverImageK** are the port used and the docker image for the receiver Application

- **HoneypotPortK** and **HoneypotImageK** are the port used and the docker image for the honeypot Applications 

- **localhoneypot1** and **localhoneypot2** are flags to determine if a local honeypot will be launched

- **HoneypotImageK2** is a test docker image that gets launched locally for testing purposes

- **etcdbrowserprovision** is a flag to determine if an etcd-browser containerized instance will be launched in GCE 

- **localKuberneteshoneypotprovision** is a flag to provision an honeypot instance inside the kubernetes environment

- **ingresslogstash** is a flag to determine if an ingress for logstash will be created 

- **instidk** is a string (that will be added as a prefix to all names of items created) to allow for multiple deployment of tc in the same AWS and GCE instances (avoiding duplicate names)  (**you MUST use lowercase string due to GCE docker machine command line limitations**)



![Alt text](/images/Cloud1.png "Cloud1")



## Kubernetes Configuration Files
Yaml files for the Kubernetes deployment are located in /kubefiles

These files start an ELK application deployed in multiple containers and publish it over the internet on a GKE cluster.

Here is a picture of the applications that get deployed on Kubernetes:

![Alt text](/images/ELK.png "ELK")

An nginx container is used to reverse proxy logstash. We used nginx in order to be able to publish an health page that is needed by GKE to provision an **healthy** load balancer:

![Alt text](/images/GKENetworking.png "GKENetworking")



## Service Discovery

All the items created by the code are registered in the KV store of **etcd** to allow for further manipulation (scaling, troubleshooting etc).



### etcd
etcd is launched as a local dockerized applications and stores variables that are used in the main Spawn, in the scale up and tear down code

**jq** is installed on the local AMI (automatically during Spawn execution) to manipulate JSON files in shell scripts

#### etcd-browser

An application (etcd-browser) has been added for showing in a web GUI the data that gets stored to etcd:

![Alt text](/images/etcd-browser.png "etcd-browser")

To enable the use of this application it is necessary to **manually** open port 4001 on the VM where the main script is launched. App port (8000) for etcd-browser needs to be opened up on your AWS security group for the launcher machine.


![Alt text](/images/Port4001.png "Port4001")

**Added value**: The etcd broswer is also useful for testing this code as you can change values inside etcd directly from its web interface


## NOTES ON using GCP

To use this script (and let it interact with Google Cloud platform) **Install the GCE SDK** on your AMI image (install and configure the SDK in the context of the ec2-user user):
- curl https://sdk.cloud.google.com | bash
- exec -l $SHELL
- gcloud init (this will start an interactive setup/configuration)
- gcloud components install kubectl (to install kubectl)


You also need to properly set up your GCE account, following are the high level steps:

- Enable the Compute Engine API

- Create credentials (Service account keys type - JSON format) and download the json file to /home/ec2-user/GCEkeyfile.json

- Enable billing for your account

- Change teh settings to have more IPs available

Finally activate your service account by issuing this command:

```
gcloud auth activate-service-account 
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
- GCP Ingresses and IPs
- Remote Kubernetes Cluster
- Infrastructure Components (etcd-browser)
- Local Docker instances (etcd if local)


###How to launch

```
./Malebolgia.sh
```

Violator.sh destroys *only the workloads deployed on Kubernetes and the local containers* but it does not remove the GKE cluster. You can then relaunch ./Spawnswarmtck to test the deployment (in a faster way).




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

# Create a geoip Map representation in Kibana

As soon as some traffic will get in from the Honeypots you should see some logs like this:

![Alt text](/images/LogsinKibana.png "LogsinKibana")

To create a geoip visuaaztion just go to the Kibana -> Visualize page add a new Tile map.

Then add a client_ipk filter on the map. You'll get a map like this showing the source IPs of all client connecting to your honeypots:

![Alt text](/images/KibanaTilemap.png "KibanaTilemap")

# Minimal Launch Instructions
Following are high level notes on how to get this running quickly:

- Start a t1.small on AWS

- Open ports for this VM on AWS
 - 22 (to reach it ;) )
 - 4001 (all IPs) for etcd-browser to reach etcd
 - 8000 for etcd-browser UI
 - 8500 (all IPs) for etcd

![Alt text](/images/MainInboundRules.png "MainInboundRules")

- Connect via SSH to your AWS instance (ie in my case: Get PuTTy configured with AWS key :P )

- Run AWSDockermachine code

- Populate /home/ec2-user/Cloud1

- Validate GCE account [ gcloud auth activate-service-account ]

- git clone this code : https://github.com/FabioChiodini/ProjectSpawnSwarmtck.git

- Launch script

# Add Ons

## Istio
A script is provided to install istio in the Kubernetes cluster.

The code is istiok.sh

The script also installs prometheus and grafana and makes grafana available via an external ip on GKE.

Grafana is published using an nginx reverse proxy and GKE ingress

## project riff
A script is provided to install project riff (FaaS for K8S) on the Kubernetes cluster

The code is in riff.sh

The script currently also install Helm in the cluster (in a specific namespace) and then uses Helm to install Project riff for serverless functions.

# ELK Versions
Logstash 5.3.2
Kibana
Elasticsearch


@FabioChiodini




