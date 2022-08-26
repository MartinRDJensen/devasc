# Notes for NX-OS Programmability for devasc
## General information about NX-OS
Used the following link:
```
https://developer.cisco.com/learning/tracks/netprog-eng/sdx-intro-nxos/
```

These are apparently some of the most important areas and respective technologies available on Cisco Nexus switches:

| Area | Technology |
|------|------------|
| Boot and Provisioning | POAP, PXE |
| Packaga and Application Management | RPM |
| Open Interfaces | Bash, Broadcom Shell, Python, Guest Shell |
| Extensibility | Containers |
| Configuration Management Tools | Puppet, Chef, CFEngine, Ansible | 
| Programmable Interface Agents | NETCONF, RESTCONF, gRPC |
| NX-OS APIs | NX-API |
| Event Management and Notification | Embedded Event Manager| 

### POAP and PXE
These are technologies that allow nexus switches upon their initial booting to download their disk images and configuration files from a preconfigered server.

### Power-On Auto Provisioning (POAP)
Enables a switch to upgrade its image on startup. Happens when upon booting the switch does not find its startup-config file. This causes the switch to search for a DHCP service on the network. When POAP gets its IP address of a script server it downloads the correct script for the switch and runs the script on the device. The script will most likely instruct the system to download and install the correct image and running-config file.

Also possible to deploy Puppet and Chef agents with POAP.During the time, the router downloads the images and running-config file, it also runs the Puppet or Chef agent executable file. When the switch comes up, the appropriate agent runs in a Linux container. Then, the agent establishes a connection with the controller Puppet or Chef server.

### Preboot Execution Environment (PXE)
Fetches an image form the network and enables automated installation and boot-up.

### Package and Application Management
Cicso Nexus switches no longer run a proprietary OS. They use a 64 bit Yocto based Wind River Linux kernel which enables bash environment on the device.

There is the YUM package manager a well.

### Open interfaces
Kind of self explanatory

### Extensibility
Containers are isolated Linux systems that share resources with the host. You can install applications using Linux containers. Either run Cisco or third-party applications such as Chef or Puppet in the container.
It does come with limited shell capabilities.

### Configuration Management Tools
Puppet, Chef and Ansible.

### NX-OS APIs
The **NX-API REST**  interface is available through HTTP/HTTPS APIs. It makes CLI commands available outside of the switch. Configuraiton commands are encoded into the HTTP/HTTPS body and use POST as the delivery method.

NX-API REST uses Nginx HTTP server as the backend.

### Evenet Management and Notification
Embedded Event Manager (EEM) is available on Cisco Nexus switches and can monitor events on devices and take actions to prevent, recover and troubleshoot based on the configuration.

EEM has 3 major components:
- **Event statements**, Events to monitor from another Cisco NX-OS component that may require an aciton, workaround or notification
- **Action statement**, action that EEM can take such as sending an email etc.
- **Policies**, an event paired with one or more actions to troubleshoot to recover form the event.

The following is an example of an EEM policy triggering and a SNMP trap to be sent to the server when the user enters global configuration mode with the *conf t* command:

```
event manager applet TEST
event cli match "conf t"
action 1.0 snmp-trap strdata "Configuration change"
action 2.0 event-default
```

## Intro to NX-API
This API has to be enabled on the Cisco Nexus switches. To check if it is enabled you can issuse:

```
device# show feature | include nxapi
nxapi	1	enabled
device#
```
which will return *enabled* if it is enabled. If the nxapi is disabled then one can enable it by:
```
device# configure terminal
Enter configuration commands, one per line. End with CNTL/Z.
device(config)# feature nxapi
device(config)#
```

From what I understand the NX-API works with Nexus managed objects along with the Data Management Engine (DME).

To work with the API we first have to obtain an authentication token from the NXOSv9k. We interact with the URL using the POST method:
```
https://sandbox-nxos-1.cisco.com/api/aaaLogin.json
```
With a body of something like:
```
{
  "aaaUser": {
    "attributes": {
      "name": "admin",
      "pwd": "Admin_1234!"
    }
  }
}
```
The following is an example of it in Python:
```
 import requests, urllib3

 # Disable Self-Signed Cert warning for demo
 urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

 # Assign requests.Session instance to session variable
 session = requests.Session()

 # Define URL and PAYLOAD variables
 URL = "https://sandbox-nxos-1.cisco.com/api/aaaLogin.json"
 PAYLOAD = {
           "aaaUser": {
             "attributes": {
               "name": "admin",
               "pwd": "Admin_1234!"
                }
             }
           }

 # Obtain an authentication cookie
 session.post(URL,json=PAYLOAD)

 # Define SYS_URL variable
 SYS_URL = "https://sandbox-nxos-1.cisco.com/api/mo/sys.json"

 # Obtain system information by making session.get call
 # then convert it to JSON format then filter to system attributes
 sys_info = session.get(SYS_URL).json()["imdata"][0]["topSystem"]["attributes"]

 # Print hostname, serial nmber, uptime and current state information
 # obtained from the NXOSv9k
 print("HOSTNAME:", sys_info["name"])
 print("SERIAL NUMBER:", sys_info["serial"])
 print("UPTIME:", sys_info["systemUpTime"])
```

**NOTE**: Through the NX-OS webserver? you can also generate python code from the cli command window. There is also the option of using Visore.

## Specific for the NX-API REST

General URL format is similar to the **ACI**:
```
<system>/api/[mo|class]/[dn|class][:method].[xml|json]?{options}
```
- *System*: System identifier; an IP address or DNS-resolvable host name
- *mo | class*: Indication of whether this is a managed object or tree (MIT) or class-level query
- *class*: Managed-object class (as specified in the information model) of the objects queried; the class name is represented as
- *dn*: Distinguished name (unique hierarchical name of the object in the MIT tree) of the object queried
- *method*: Optional indication of the method being invoked on the object; applies only to POST requests
- *xml | json*: Encoding format
- *options*: Query options, filters, and arguments















