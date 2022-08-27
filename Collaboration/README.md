# Collaboration Notes

## Authorization
There is the Personal Access Token.

## Webex REST API
Allows you to interact with Webex's main concepts:
- *Rooms*: Create, update, or delete spaces
- *Teams*: Create, update, or delete teams
- *People*: Look for webex users
- *Messages*: Create or delete messages
- *Memebership* and *team memberships*: add, remove participants from spaces and teams.

In general there is the URL API, XMLAPI, TS API?

The API enables you to interact with Webex's main concepts:

Rooms: Create, update, or delete spaces.
Teams: Create, update, or delete teams.
People: Look for Webex users.
Messages: Create or delete Messages.
Memberships and Team Memberships: Add, remove participants from spaces and teams, and promote participants as moderators.

there is also webhooks to be notified about various events.

https://developer.webex.com/docs/platform-introduction

To get the access token for the Webex REST API you would login and navigate to accounts and authentication to find your personal access token.

There are kind of 3 different applications mentioned that you can built using Webex REST API:
- Controller: listens for events in Webex, such as specific mention, or people being added. With event the app can send an SMS alert or something similar.
- Notifier: responds to events by sending messages to a Webex space.
- Interactive Assistants: asks customers a set of questions and uses answers to perform actions such as filling out a form. Can be thought of as a chat bot


## Webex Integration
Webex integrations use OAuth Grant Flow protocol to issue the access tokens that can act under Webex uses' identities. Tokens are scoped
- API Access Token
  - Developer
    - code acts under your Cisco Webex Teams identity
  - Bot account
    - code acts under its own identity and is identifiable as a Bot among Webex Teams users
  - OAuth Integration
    - code acts on behalf of Cisco Webex Teams users identity thanks to OAuth scoped tokens.


The URL for Webex is something like this but specific to rooms:
https://webexapis.com/v1/rooms/{roomId}/


## Webex SDKs
With the SDKs, you get fine-grain control of the user experience and how the video, or messaging, or meeting capabilities are presented. The Webex SDKs let you initiate calls to other Webex clients, phones and rooms, PSTN numbers or SIP URIs, and receive or answer incoming calls, perform 1:1 and group persistent chat, and join Webex meetings.

## Webex Widgets
The Webex Widgets are the quickest way to integrate the Webex user experience: by pasting a few lines of HTML and Javascript code, you can bring calling, messaging, and meeting features to existing Web applications. The widget provides a full Webex UI experience within its container as defined by the web page author.




EXPERIMENT WITH WEBEX WEBHOOKS
Webhooks are an application's way of receiving notification from the Webex platform when an "event" occurs.
You can think of webhooks as "reverse APIs" where the Webex cloud platform posts data to your application (instead of the other way around).

POST https://webexapis.com/v1/webhooks

















