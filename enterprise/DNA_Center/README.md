# DNA Center Notes

## Authentication
To authenticate to the DNA Center you would send a POST request to:
```
https://sandboxdnac.cisco.com/dna/system/api/v1/auth/token
```
With the Authorization request header set to basic authentication so something like
```
Ahtorization: Basic base64(username:pwd)
```
Then you would send this request and receive the authorization token for later use. To use the token you have to specify it with the **X-Auth-Token** header.
```
X-Auth-Token: tokenval
```

A sample of how to do it in python:
```
endpoint = '/dna/system/api/v1/auth/token'
dna_ip = "placeholder"
url = f"https://{placeholder}{endpoint}"

# Make the POST Request
resp = requests.post(url, auth=HTTPBasicAuth('username', 'password'), verify=False)

# Retrieve the Token from the returned JSON
token = resp.json()['Token']

# Print out the Token
print("Token Retrieved: {}".format(token))
```

## Working With Network Devices
The URL for working with network devices is:
```
https://sandboxdnac.cisco.com/api/v1/network-device
```
When using the endpoint remember to set the **x-auth-token** request header.

You can query a specific device if you know the managementIpaddrss or macAddress:
```
https://sandboxdnac.cisco.com/api/v1/network-device/?managementIpAddress=10.10.22.74&macAddress=00:c8:8b:80:bb:00
```
Not entirely sure if the macAddress is formatted correctly

Example for getting the list of devices:
```
token = get_auth_token() # Get Token
url = "https://sandboxdnac.cisco.com/api/v1/network-device"
hdr = {'x-auth-token': token, 'content-type' : 'application/json'}
resp = requests.get(url, headers=hdr, verify=False)  # Make the Get Request
device_list = resp.json()
```

The Learning Labs provide the following Python example for retrieving a list of all interfaces to a specific device:

```

import requests
from requests.auth import HTTPBasicAuth
from dnac_config import DNAC_IP, DNAC_PORT, DNAC_USER, DNAC_PASSWORD


def get_device_list():
    """
    Building out function to retrieve list of devices. Using requests.get to make a call to the network device Endpoint
    """
    global token
    token = get_auth_token() # Get Token
    url = "https://sandboxdnac.cisco.com/api/v1/network-device"
    hdr = {'x-auth-token': token, 'content-type' : 'application/json'}
    resp = requests.get(url, headers=hdr)  # Make the Get Request
    device_list = resp.json()
    get_device_id(device_list)


def get_device_id(device_json):
    for device in device_json['response']: # Loop through Device List and Retrieve DeviceId
        print("Fetching Interfaces for Device Id ----> {}".format(device['id']))
        print('\n')
        get_device_int(device['id'])
        print('\n')


def get_device_int(device_id):
    """
    Building out function to retrieve device interface. Using requests.get to make a call to the network device Endpoint
    """
    url = "https://sandboxdnac.cisco.com/api/v1/interface"
    hdr = {'x-auth-token': token, 'content-type': 'application/json'}
    querystring = {"macAddress": device_id} # Dynamically build the query params to get device specific Interface information
    resp = requests.get(url, headers=hdr, params=querystring) # Make the Get Request
    interface_info_json = resp.json()
    print_interface_info(interface_info_json)


def print_interface_info(interface_info):
    print("{0:42}{1:17}{2:12}{3:18}{4:17}{5:10}{6:15}".
          format("portName", "vlanId", "portMode", "portType", "duplex", "status", "lastUpdated"))
    for int in interface_info['response']:
        print("{0:42}{1:10}{2:12}{3:18}{4:17}{5:10}{6:15}".
              format(str(int['portName']),
                     str(int['vlanId']),
                     str(int['portMode']),
                     str(int['portType']),
                     str(int['duplex']),
                     str(int['status']),
                     str(int['lastUpdated'])))


def get_auth_token():
    """
    Building out Auth request. Using requests.post to make a call to the Auth Endpoint
    """
    url = 'https://sandboxdnac.cisco.com/dna/system/api/v1/auth/token'       # Endpoint URL
    resp = requests.post(url, auth=HTTPBasicAuth(DNAC_USER, DNAC_PASSWORD))  # Make the POST Request
    token = resp.json()['Token']    # Retrieve the Token
    return token    # Create a return statement for the Token


if name == "main":
    get_device_int()

```




