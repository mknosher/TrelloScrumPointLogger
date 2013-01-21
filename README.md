TrelloScrumPointLogger
======================

A NodeJS, Express-based application for logging and tracking scrum points on Trello

A scrum point addon to Trello can be found in the Chrome Web Store:
https://chrome.google.com/webstore/detail/scrum-for-trello/jdbcdblgjdpmfninkoogcfpnkjmndgje

This is currently a web app that is designed to be used by a single person. Via oauth it retrieves and stores an application token that is used to access private boards.

appSettings.json
----------------

To use this app, you will need to create "appSettings.json" in the root directory of the project. It stores the private Trello information as well as general config. Below is a guide to the structure of this file... 

{
    "apiKey" : "<your_trello_api_key>",
    "oAuthSecret" : "<your_trello_oauth_secret>",
    "boardId" : "<board_id>",
    "domain" : "<your_domain>",
    "port" : <your_port>
}

You will need to generate your Trello api key and oauth secret using https://trello.com/1/appKey/generate.
