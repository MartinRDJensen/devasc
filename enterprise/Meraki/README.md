# Meraki Notes
There are 5 ways that an app can extend Meraki platform functionality:
- **Dashboard API**, provides RESTful service for device provisioning, management, and monitoring.
- **WebHook Alerts**, real-time notification system for network events and health.
- **Location Scanning API**, HTTP POST method configured on the Meraki Dashboard providing client location information based on Meraki Access Point map placement and client signal strength. Uses WiFi + BLE
- **MV Sense**, combination of REST APIs and realtime MQTT stream that allows for oversight of a physical space using MV series cameras.
- **External Captive Portal (EXCAP)**, allows organization to build out custom engagement models for devices using their WiFi environment.

## Meraki Dashboard API
Is a RESTfful API that uses HTTPS for transport and JSON for object serialization.
You have to enable **Dashboard API access**. After enabling the API go to **My Profile** page to generate an API key.

### Authorization
Each request must specify an API key via a request header. Returns HTTP status code 404 instead of 403 if missing or incorrect API key.
The HTTP header that you have to set is:
```
X-Cisco-Meraki-API-Key: <secret key>
```

cURL example of the Dashboard API:
```
curl --request GET -L \
  --url https://api.meraki.com/api/v1/organizations \
  --header 'X-Cisco-Meraki-API-Key: 6bec40cf957de430a6f1f2baa056b99a4fac9ea0'

#Reponse might contain something like
#[{"id":549236,"name":"DevNet Sandbox"}]
```
The Meraki Dashboard API has a few hundred endpoints allowing a Meraki network administrator to provision, set configurations, monitor, and manage Meraki networks and their respective devices.

## Meraki Webhook Alerts
Meraki webhooks are a powerful and lightweight way to subscribe to Meraki Cloud alerts. A webhook includes a JSON-formatted message and is sent to a unique URL where it can be processed, stored, or used to trigger powerful automations.

Webhooks support all configurable alert types that are available in dashboard under **Network-wide > Configure > Alerts**.

### Webhook Setup
To configure a webhook you have to navigate to **Network-Wide > Configure > Alerts**. Then you would add an HTTP server.

To set up webhooks dynamically with the API you would use HTTP POST to both *alertSettings* and *httpServers*.
```
https://api.meraki.com/api/v0/networks/networkId4/alertSettings
https://api.meraki.com/api/v0/networks/networkId4/httpServers
```

## Meraki Location Scanning API
The location API delivers data from the Meraki cloud and you can use the API to detect WiFi (associated and nonassociated) and Bluetooth Low Energy (BLE) devices. The API exports the elements with an HTTPS POST of JSON data to a specified destination server.

Using the physical placement of the access points from the Map & Floorplan on the Dashboard, the Meraki cloud estimates the location of the client.

This API has a lot of different Data Elements (google it for reference).

You have to **enable** the Scanning API. This is done with these steps:
- Turn on the API 
- Specify POST URL and the authentication secret.
- Specify which scanning API version your HTTPS server is prepared to receive and process.
- Configure and host your HTTPS server to receive JSON objects.
Upon first connection Meraki cloud performs a single HTTP GET. The server must return the organization-specific validator string as a response, which verifies the organization's identity as a Meraki customer. The Meraki cloud then begins performing JSON posts. 

### Bluetooth Scanning API
To enable location finding for BLE devices, enable the BLE scanning radio on the Access Points. BLE Scanning is enabled in Wireless > Bluetooth Settings > Scanning.

## Meraki MV Sense
With a powerful onboard processor and a unique cutting-edge architecture, Meraki Smart Cameras run object detection, classification, and tracking directly on the edge. 
The API endpoints of MV Sense make this machine learning and computer vision data available for you to use in your applications, providing high-value data and business insights without the high-cost compute infrastructure that is typical in computer vision and video analytics. 

Through both REST and MQTT API endpoints, request or subscribe to historical, current, or real-time data that are generated in the camera to feed into your application and start using your camera for more than just security.

There are **several camera APIs**:
- MV Sense, includes REST and MQTT API endpoints which provide historical and real-time people detection data and light readings.
- Live Link API, REST API which returns a Dashbaord link for a specified camera
- Snapshot API, REST API generates a snapshot of the specified camera's field of view at a specific time and returns a link to that image.

### REST vs MQTT APIs
- *REST-based*, offer an on-demand between the client and the server so a connection will be made only when data is requested. The server must wait for the clients to connect, leading to a slight delay in data delivery when sending requests to your camera. Using the MV Sense REST APIs enable you to gain historical or near real-time people detection data from your camera.
- *MQTT-based*, use a publish-subscribe connection between the client and server. In the case of MV Sense, the server is continuously pushing messages to the MV smart cameras so the device can respond instantly. This leads to a real-time feed of data coming from your camera.

## Meraki External Captive Portal
A user sees a captive portal (also known as a “splash page”) when they first associate with a Wi-Fi SSID and open a web browser to surf the internet. When you configure a captive portal, all internet traffic redirects to a specified URL.

## More On Meraki Dashboard API 
Base URL is:
```
https://api.meraki.com/api/v1
```
The request header that should have the authorization is:
```
X-Cisco-Meraki-API-Key
```
To list the organizations you would use the resource url. This is done with the GET request method:
```
https://api.meraki.com/api/v1/organizations
```
To get the networks in an organiation then you can use the following API call:
```
https://api.meraki.com/api/v1/organizations/{{organizationId}}/networks
```
To further get the devices in a network you would use the follwing URL:
```
https://api.meraki.com/api/v1/networks/{{networkId}}/devices
```
To get network information you would use the following URL:
```
https://api.meraki.com/api/v1/networks/{{networkId}}

#Result would be something like:
{
    "id": "L_566327653141856846",
    "organizationId": "681155",
    "type": "combined",
    "productTypes": [
        "switch",
        "wireless"
    ],
    "name": "DevNetLab",
    "timeZone": "America/New_York",
    "tags": "",
    "disableMyMerakiCom": false,
    "disableRemoteStatusPage": true,
    "enrollmentString": null
}
```
To get device specific information we would use the serial number? The URL is the following:
```
https://api.meraki.com/api/v1/devices/{{serial}}

#Would return something like:
{
    "lat": 37.4180951010362,
    "lng": -122.098531723022,
    "address": "",
    "serial": "Q2KD-KWMU-7U92",
    "mac": "e0:cb:bc:8c:1f:fe",
    "lanIp": "192.168.128.5",
    "networkId": "L_566327653141856846",
    "model": "MR42",
    "firmware": "wireless-25-13",
    "floorPlanId": null
}
```
Lastly, to get SSID information you would use the URL:
```
ttps://api.meraki.com/api/v1/networks/{{networkId}}/wireless/ssids
```










