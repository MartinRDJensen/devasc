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








