# Notes on security

## Cisco Firepower NGFW
- threat focused stops vulnerability exploitation
- single OS + single management
- supported by Talos
- Much more

## Firepower Management Center (FMC)
- AMP
- Security intelligence
- HA
- API/pxGrid integration
- role based access control
- firewall and AVC
- managefirewalls across many sites, control access and set policies, investigate incidents, prioritize reponse

Typical management is device CLI & FMC GUI session
It enables FMC API.
- allows northbound integrations
- suitable for large deployments that need faster rollouts of change across larger quantity NGFW/IPS appliance

For now FMC only supports JSON
The internal API Explorer tool:
- resides on the FMC
- allows interactive modeling of REST API syntax
- creates/exports python or perl scripts

FMC REST API Use Cases
- Compliance Tool (READ operations)
  - 3rd party compliance contractor may directly read/audit policy configurations via the API.
  - If you have multiple FMCs you want to have similar policies for compliance. You can get all the policies and store them in one place.

- Policy Change/Addition
  - Bulk changes to push to FMCs etc. Widely used use case for the REST API.
  
- Migration Tool\
  - Use REST API to read data from one box and subsequently write that data to another. 


### FMC REST API
The REST API has to be enabled on the FMC

To add a device you first have to go to the firewall and make sure it has a manager:
```
> show manager
No managers configured.
> configure manager add 1.20.0.3 sharedsecret123
```

Then you can add it  to the firewall;
You would usually also have a policy created as the policy will be linked with the device using the policy ID.
You also need smartLicenses????

On successful creation you will receive a task ID as the registration of a device is not instant.
You can check the status using the task ID.

For FMC to generate the token you have to use a POST request with BASIC Authentication.
```
/api/fmc_platform/v1/auth/generatetoken
```
The reply will be in x-auth-access-token which will be valid for around 30 minutes
The x-auth-refresh-token is for refreshing the access token valid for around 1-2 hours?

## Overview of Firepower Threat Defense

What is the Firepower Device Manager (FDM)?
- on device web based manager
- provides ease of use in next generation firewall management
- Modern web stack purpose built on RESTFUL device API
- Aimed at small to medium sized business
- New features added each release

Firepower Threat Defense (FTD) REST API:
- OAuth authentication
- In built web based API Explorer. Browsable with Swagger API browser
  - defined with Open API specification
- REST API functionality matches Firepower Device Manager UI.

Co-existence with other tools:
- FDM and the FTD API can be used in parallel with the Cisco Defense Orchestrator which is a cloud based management tool.
- FDM is built on the FTD API
- FMC does not yet co-exist with the FDM/CDO/FTD API (must choose up front)

Scenarios for FDM/FTP API
- small number of devices
- small to medium sized feature needs
- Has external analytics box or doesn't need advanced analytics
- Also useful for service providers / managed service providers
  - API automation

FDM/FTP API Key functionality
- Interface configuration
- Routing
- VPN
- Policies
- Policy Objects
- System Settings
- and more














