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

## Firepower Management Center API
You have to enable API access on the FMC.

### Authentication
Then to use it you have to retrieve an authentication token. This is done by using a GET request along with username and password of the API user. The URL to use is the following:
```
https://<management_center_IP_or_name>/api/fmc_platform/v1/auth/generatetoken
```
where the username and password are included as a basic authentication header.

In the output of the response you will receive 3 tings:
- The header X-auth-access-token:<authentication token value> which is to be used in requests to the API.
- The headers X-auth-access-token:<authentication token value> and X-auth-refresh-token:<refresh token value> is used to refresh the token.
- Use the Domain_UUID from the authentication token in all REST requests to the server.

**Token refreshing**
The token will be valid for 30 minutes and can be refreshed 3 times by sending POST requests to :
```
https://<management_center_IP_or_name>/api/fmc_platform/v1/auth/refreshtoken
```
and adding the token and refresh token in the header:
```
X-auth-access-token:<authentication token value>
X-auth-refresh-token:<refresh token value>
```

**General steps of getting an authentication token**:
- Use API credentials
- POST to:
  ```
  https://<management_center_IP_or_name>/api/fmc_platform/v1/auth/generatetoken 
  ```
  with no body and a basic authentication header.
- Store the important headers from the response:
  - X-auth-access-token
  - X-auth-refresh-token
  - Domain UUID

### Getting a info about connected devices
Use a GET request to the following endpoint to receive the currently managed devices from your FMC:
```
https://{{fmc_ip}}//api/fmc_config/v1/domain/{{domain_uuid}}/devices/devicerecords
```
To then get detailed device information from a manged devices you would use:
```
https://{{fmc_ip}}//api/fmc_config/v1/domain/{{domain_UUID}}/devices/devicerecords/{{object_UUID}}
```

## Working with the Firepower Device Manager APIs
### The API Explorer
It is accessible over:
```
https://<NGFW_management_IP_or_name>/#/api-explorer
```
Some URLs have 2 levels:
- /object/networks
- /object/networks/{objId}
where the first is for fetching all networks and the second one would feetch, update, or delete an individual instance.

It can generate JSON format for you.

### Getting the access token
POST method to:
```
https://ftd.cisco.com/api/fdm/v6/fdm/token.
```
With "No Auth". For the request headers you have to specify *Content-Type* and *Accept* as application/json and finally the request payload should include the following:
```
{
 "grant_type": "password",
 "username": "admin",
 "password": "Admin123"
}
```
This will in turn give you an **access_token**.

### The FTD API
To interact with the FTD device, you must authenticate with an authentication token from the FTD device. To request this token, you need the device's IP address, and an FTD administrator username and password. This information is stored in an initialization YAML file.
The YAML file should have something like:
```
---
devices:
  - hostname: FDM_DEVICE
    ipaddr: 192.168.100.1
    port: 443
    username: admin
    password: Cisco123
    version: 4
```
Sample code for interacting with the **FTD device** in python from the learning labs:
```
profile_filename="profile_ftd.yml"
new_auth_token=['none']#as global variable in order to make it easily updatable

# thirdly let's defined some base function

def yaml_load(filename):
    '''
    load FTD device information for connection
    '''
    fh = open(filename, "r")
    yamlrawtext = fh.read()
    yamldata = yaml.load(yamlrawtext,Loader=yaml.FullLoader)
    return yamldata

def fdm_login(ipaddr,username,password,version):
    '''
    This is the normal login which will give you a ~30 minute session with no refresh.  
    '''
    headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization":"Bearer"
    }
    payload = {"grant_type": "password", "username": username, "password": password}

    request = requests.post("https://{}:{}/api/fdm/v{}/fdm/token".format(ipaddr, FDM_PORT,version),json=payload, verify=False, headers=headers)
    if request.status_code == 400:
        raise Exception("Error logging in: {}".format(request.content))
    try:
        access_token = request.json()['access_token']
        fa = open("./temp/token.txt", "w")
        fa.write(access_token)
        fa.close()    
        new_auth_token[0]=access_token
        print (green("Token = "+access_token))
        print("Saved into token.txt file")        
        return access_token        
    except:
        raise

def fdm_get_hostname(ipaddr,token,version):
    '''
    This is a GET request to obtain system's hostname.
    We will use it to verify that the token we got works
    '''
    headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization":"Bearer {}".format(token)
    }
    try:
        request = requests.get("https://{}:{}/api/fdm/v{}/devicesettings/default/devicehostnames".format(ipaddr, FDM_PORT,version),
                           verify=False, headers=headers)
        return request.json()
    except:
        raise

# Here under our main function from which are called all above functions
# Note that name and main should have double underscores __ on either side
if __name__ == "__main__":
    #  load FDM IP & credentials here under
    ftd_host = {}
    ftd_host = yaml_load(profile_filename)    
    pprint(ftd_host["devices"])    
    FDM_USER = ftd_host["devices"][0]['username']
    FDM_PASSWORD = ftd_host["devices"][0]['password']
    FDM_IP_ADDR = ftd_host["devices"][0]['ipaddr']
    FDM_PORT = ftd_host["devices"][0]['port']
    FDM_VERSION = ftd_host["devices"][0]['version']

    token = fdm_login(FDM_IP_ADDR,FDM_USER,FDM_PASSWORD,FDM_VERSION)

    # save token into token.txt file

    fa = open("./temp/token.txt", "w")
    fa.write(token)
    fa.close()
    print()    
    print(yellow("BINGO ! You got a token ! :",bold=True))
    print()     
    print()     
    print ('==========================================================================================')
    print()
    x=input("Let's check it. Type Enter")
    hostname = fdm_get_hostname(FDM_IP_ADDR,token,FDM_VERSION)
    print ('JSON HOSTNAME IS =')
    print(json.dumps(hostname,indent=4,sort_keys=True))    
    print()
    print(green('  ===>  ALL GOOD !',bold=True))
    print()
```
Here is an example for getting an access_token from the FTD API (again from the learning labs):
```
def fdm_login(ipaddr,username,password,version):
    '''
    This is the normal login which will give you a ~30 minute session with no refresh.  
    '''
    # We built the http header
    headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization":"Bearer"
    }
    # We built the payload to post within the REST call
    payload = {"grant_type": "password", "username": username, "password": password}

    # We send the REST Call to the FTD device
    request = requests.post("https://{}:{}/api/fdm/v{}/fdm/token".format(ipaddr, FDM_PORT,version),json=payload, verify=False, headers=headers)
    if request.status_code == 400:
        raise Exception("Error logging in: {}".format(request.content))
    try:
        # Post was succesful we parse the access_toke from the JSON result
        access_token = request.json()['access_token']
        return access_token
    except:
        raise
```
And another example of getting the device hostname (also from the learning labs):
```
def fdm_get_hostname(ipaddr,token,version):
    '''
    This is a GET request to obtain system's hostname. 
    We will use it to verify that the token we got works
    '''
    # As we already have an authenticatio token we add it in the http header as a bearer token.
    headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization":"Bearer {}".format(token)
    }
    try:
        # Here under the GET REST Request
        request = requests.get("https://{}:{}/api/fdm/v{}/devicesettings/default/devicehostnames".format(ipaddr, FDM_PORT,version),
                           verify=False, headers=headers)
        return request.json()
    except:
        raise
```

### FTD API a review
The URL is a concatenation of the FTD management IP address, a base URL, an API version, and an API path:
```
https://{managementIP}/api/fdm/v5/object/networks/{objectId}
```
is an example. ALso for each request the following have to be set:
```
headers = {
	"Content-Type": "application/json",
	"Accept": "application/json",
	"Authorization":"Bearer {}".format(token)
}
```


## Cisco Umrella APIs
The two main APIs that umbrella has is the **enforcement** and the **investigate** APIs.
There are some other APIs such as:
- The reporting API (most recent requests, top idneitties, security activity)
- Network Device Management API (so you can register network devices as identities to the umbrella dashboard)
- Partner & Provider console reporting API 

### Umbrella Enforcement API
You can integrate SIEM or Threat Intelligence Source to inject events into the Umbrealla environment.

These events can be used in custom integration with Umbrella to add additional domains to block. There is existing integration with Splunk?
You can make up to 10 custom integrations and there is no need for Cisco Threat Response!

Example workflow:
- external source identifies malicious activity with a Domain as an Observable.
- Event is sent to Umbrella Security Platform API via a POST request.
- Before the domain, included in the API POST, is added to the specific Umbrella customer's block list a check is performed.

Before anything is added there is an Umbrella API-based Domain Acceptance Process:
- Is the domain present in the customer's allow list within the organization? (allow list overrules any custom or Umbrella owned block list)
- Does the domain already exist in the global block list under the security cetagory (score -1)?
- Is the status uncategorized?
- Is the domain considered benign/safe (score +1) under the Cisco Umrella Investigate?

The Enforcement API uses an **API key** that is send along in the **URI**. All API requests must be made over **HTTPS**. You would obtain the key form the Umbrella Dashboard (Policies  > Integrations).
The Enforcement API supports:
- POST requests (reply gives 202)
- GET requests (success is 200)
- DELETE requests (success is 204)

### Umbrella Investigate API
- Can be used to automate enrichment of context regarding an observable:
  - Check security status of a domain, IP, or a subset of domains
  - Determine co-occurring domains
  - Find historical record for domain or IP
  - Query large number of domains quickly
  - Add context to events in Splunk.
- Is rate limited
- Extra license needed on top of Umbrella Platform
- Needed for Cisco Threat Response (might change).

Requires HTTPS for all API requests. Must supply valid access token. The Authentication to the API occurs using basic auth (Bearer token).
To obtain the key from the Umbrella Dashboard (Admin > API Keys)










