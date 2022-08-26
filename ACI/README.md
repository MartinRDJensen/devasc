# Following is the notes for the Cisco ACI Programmability

## Introduction to ACI Programmability
ACI is Cisco's SDN solution for the data center.

ACI is for the data center and in the data center Cisco uses Nexus 9000 switches. This switch has two modes of operation **NX-OS** mode and **ACI** mode.

For the NX-OS mode the switch uses the traditional OS with enhancements to provide support for network deployments while keeping the options for using next-generation data center protocols/technologies.
You have an option for standalone or device by device level programming using APIs.

With the ACI mode the infrastructure is centrally managed by a cluster of controllers. These controllers are called Application Policy Infrastructure Controllers (APICs).

In ACI mode switches oeprate either as a Spine or a Leaf switch. Spine leafs aggregate leaf switches and leaf switches are used as access devices. Nexus switches running the ACI mode are only programmable using **object-based policy engine** operating on the APIC controller. The controller holds the profiles containing the policies for programming switches centrally.

The ACI core components are:
- Leaf switches which provide connectivity into the Fabric. Serve as distributed L3 gateways, the policy enforcement points and gateways to external networks.
- Border Leaf switches which is any leaf node that connects to a network device external to the ACI fabric.
- Spine switches which provide a non-blocking fabric with rapid failure detection and re-routing. Used to forward traffic between two leaf switches.
- APIC controllers which provide the centralized point of management for fabric configuration and observing summary states. From policy perspective the APIC is the point of contact for configuration and acts as the policy repository.

### Tenants
Tenants is the top-level object that identifies and separates administrative control, network/failure domains, and application policies. Sublevel can be grouped into two categories the **Networking** and **Policy**.
The Tenant Networking consists of:
- VRFs, are isolated routing tables for the Tenant. The Tenant can have one or many VRFs.
- Bridge Domains, L2 forwarding domains within the fabric and define the unique MAC address space and flooding domain (broadcast, unknown unicast, multicast). Associated with only one VRF but a VRF can have many bridge domains. Unlike VLANs bridge domains can contain multiple subnets.
- Subnets, L3 networks that provide IP space and gateway services for hosts to connect the network. Each subnet is connected with only one bridge domain.
- External Bridge Networks, connects a L2/STP network to the ACI fabric. To allow for smooth integration from traditional network infrastructure to an ACI network.
- External Routed Networks, creates L3 adjacency with a network outside the ACI fabric. Supports adjacencies using static routes or BGP, OSPF, and EIGRP.

The Tenant Policy consists of:
- Application profiles, Container for EPGs. Is used as an identifier for applications, and allows for separation of administrative privileges.
- End Point Groups (EPGs), collection of endpoints that has same services and policies applied. Define switchports, virtual switches, L2 encapsulation associated with an application service. Each EPG can only be related with one Bridge Domain.
- Contracts, define the services and policies that are applied to an EPG. Contracts can be used for service redirection to an L4-L7 device, assiging QoS values and applying ACL rules.
- Filters, objects that define protocols (TCP, UDP, ICMP, and so on) and ports. Filter objects can contain multiple protocols and ports. Contracts can consume multiple Filters.

### The Object Model

- ACI operates on an object-based model, which is used to configure and manage ACI.
- Object model has two categories, the logical and concrete.
- Changes are made to the logical model and pushed down to the concrete model where the hardware and software are programmed as needed.
- Managed objects (MOs) are connected in a parent/child relationship forming the Management Information Tree (MIT). The root has no parent.
- Each MO has a Relative Name (RN) which identifies an object from other child objects of the same parent. Each RN has to be unique within the parent object. Relative names begin with a **class prefix** and is based off the object's class type.
- Distinguished names are the unique name of objects in the MIT. It contains a series of RNs starting with the root and attaching each child RN down to the object.

### ACI REST API
- Supports all four CRUD methods.
- To login you use HTTP post with a JSON body:
```
Method: POST
URL: https://sandboxapicdc.cisco.com/api/aaaLogin.json
Body:
{
    "aaaUser": {
        "attributes": {
            "name": "admin",
            "pwd": "!v3G@!4@Y"
        }
    }
}
```
- To make a class query for all applications configured on the ACI fabric:
```
Method: GET
URL: https://sandboxapicdc.cisco.com/api/class/fvAp.json?
```

ACI has a toolkit called **acitoolkit** and the basic workflow is the following:
```
from acitoolkit import acitoolkit
#create session
#url, login and password are params
session = acitoolkit.Sesssion(URL, LOGIN, PASSWORD)
session.login() #should give 200 response code

#create tenant 
new_tenant = acitoolkit.Tenant("name_of_tenant")

#commit the configuration
#should return 200 response code
session.push_to_apic(new_tenant.get_url(), new_tenant.get_json())
```
The acitoolkit also has cool things such as tenant visualiser tool and much more!

There is also the Cobra SDK which is a Python SDK that supports CRUD operations on the ACI fabric. It is a complete mapping of the object-model so it is more complex than acitoolkit.

```
from credentials import *
import cobra.mit.access
import cobra.mit.request
import cobra.mit.session
import cobra.model.fv
import cobra.model.pol

# connect to the apic
auth = cobra.mit.session.LoginSession(URL, LOGIN, PASSWORD)
session = cobra.mit.access.MoDirectory(auth)
session.login() # <Response [200]>

# Create a Variable for your Tenant Name
# Use your initials in the name
# Example: tenant_name = "js_Cobra_Tenant"
tenant_name = "INITIALS_Cobra_Tenant"

# create a new tenant
root = cobra.model.pol.Uni('')
new_tenant = cobra.model.fv.Tenant(root, tenant_name)

# commit the new configuration
config_request = cobra.mit.request.ConfigRequest()
config_request.addMo(new_tenant)
session.commit(config_request)
```

Since the Cobra SDK is very complex there is APIC REST Python Adapter (Arya) which assists with generating a Python script using the Cobra libraries. Takes XML or JSON as input and outputs python code used to generate same configuration.

### API URL
The URL follows the following format:
```
https(s)://host:port/api/{mo|class}/{dn|classname}.{xml|json}?[options]
```
The class names used by the MIT is:
- fvTenant is the Tenant
- fvCtx is the VRF (orginally named Context)
- fvBD is the Bridge Domain
- fvAp is the Application
- I3extOut is the L3 External Out

### Visore
Visore is an object-browser built into the APIC. Reached at:
```
https://sandboxapicdc.cisco.com/visore.html
```

The ACI API has **scoping filters** to expand the query to the children of a DN.

### API Inspector
Used to capture API requests being made to the controller. The APIC GUI is itself an API client and makes API requests to the underlying APIC controllers. The API Inspector allows you to sniff these requests to see which API calls are being made.

### Cobra script structure
- First step is to login which requires session and access modules
```
# import statements
import cobra.mit.session
import cobra.mit.access

# establish a session with the APIC
#URL, LOGIN, PASSWORD should be replaced of course
auth = cobra.mit.session.LoginSession(URL, LOGIN, PASSWORD)
session = cobra.mit.access.MoDirectory(auth)
session.login()

#We can then query for Tenants named Heroes with the DN query
import cobra.mit.request

tenant_query = cobra.mit.request.DnQuery("uni/tn-Heroes")
heroes_tenant = session.query(tenant_query)

#We can go through all the App Profiles
app_query = cobra.mit.request.ClassQuery('fvAp')
apps = session.query(app_query)
for app in apps:
    print(app.name)

#Instead of return all we can scope the query to those named "Save_The_Planet"
# set the property filter to only return the app named "Save_The_Planet"
app_query.propFilter = 'eq(fvAp.name, "Save_The_Planet")'
save_the_planet_app = session.query(app_query)

print(save_the_planet_app[0].name) #returns the name 
```
## ACI Websockets
Enables bi-directional communication between two hosts.
- enables the server to send and push messages to the client
- use a single TCP connection for all communication
- ws:// for plain text communication, wss:// for encrypted traffic
- You would use token from the login procedure

To open the websocket you would use:
```
wss://sandboxapicdc.cisco.com/socket%TOKEN%
```

To subscribe you would use GET requests to the Class or MO URL followed by **subscription=yes**. As an example we can subscribe to the Heroes Tenant:
```
HTTP Method: GET
URL: https://sandboxapicdc.cisco.com/api/mo/uni/tn-Heroes.json?subscription=yes
```

## ACI and Ansible
#### Intro
There are ACI modules for Ansible. The ACI Ansible modules work like you expect an Ansible Module to behave: they have fixed parameters that are used to connect to and configure the remote device. In this case, the Application Policy Infrastructure Controller of APIC. The ACI modules are idempotent and only push configurations when the module's parameters are different than what currently exists, and return back the status of the module's execution and what changes were made, if any.

There are 4 main types of ACI modules:
- Tenant modules, used to manage Tenant configurations, including App Profiles, EPGs, VRFs, Bridge Domains, and Policy configurations.
- Infrastructure modules, used to interact with the Fabric inventory and switchport policies.
- Configuration Management, supports creating snapshots, previewing configuration differences, and performing rollback to previous snapshot.
- General purpose module(s), used for any feature that does not have a module. Can be used to make any request to the API using data stored in JSON or XML.

Common ACI Module parameters are:
- hostname
- username
- password
- use_ssl, used to determine whether to use http or https
- validate_certs, used to determine whether to validate the APIC's certificate against the server's known_hosts file. Default is True.
- state (present, absent, query (retrieve a list of existing configuration for the object or class))
- description

## ACI and Terraform
Terraform is a way to automate ACI. The benefit is that the, specifically for Terraform resources and data sources for ACI, is that it removes the need to write custom scripts.

Terraform resources are pre-written blocks of code that does a specific task. Saves you time from researching API requests, developing code to make proper API requests, and then testing and debugging it.

### The Terraform Provider
- is a set of resources and data sources that allow the Terraform binary to ineract with third-party system.
- Use **resource** to add, modify, or destroy a unit of infrastructure.
- Use **data source** to represent an existing unit of infrastructure to be able to interpolate or reference it in other resources or data sources.
- For **ACI Terraform Provider** these resources and data sources represent the ACI Configuration elements of the APIC.

To use a Terraform provider you have to define it in the Terraform plan. The **Terraform plan** is a configuration file which describes the providers, resources, and data sources that represent infrastructure using **HashiCorp Configuration Language (HCL)**.
The default Terraform plan is named main.tf

Example:
```
terraform {
  required_providers {
    aci = {
      source = "CiscoDevNet/aci"
    }
  }
}

# Configure the provider with your Cisco APIC credentials.
provider "aci" {
  # APIC Username
  username = var.user.username
  # APIC Password
  password = var.user.password
  # APIC URL
  url      = var.user.url
  insecure = true
}
```










