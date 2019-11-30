package main

import (
	"github.com/nlopes/slack"
	"log"
	"os"
)

func main() {
	apiToken := os.Getenv("SLACK_TOKEN")
	channel := os.Getenv("SLACK_CHANNEL")
	appID := os.Getenv("APP_ID")
	api := slack.New(apiToken)

	message := "[" + appID + "] " + os.Args[1]

	channelID, timestamp, err := api.PostMessage(channel, slack.MsgOptionText(message, false))
	if err != nil {
		log.Printf("Error: %s\n", err)
		return
	}
	log.Printf("Message successfully sent to channel %s at %s\n", channelID, timestamp)
}
