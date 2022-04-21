package main

import (
	"log"

	"math/rand"
	"time"

	tea "github.com/charmbracelet/bubbletea"
)

func main() {
	rand.Seed(time.Now().UTC().UnixNano())

	if model, err := tea.NewProgram(InitialPage()).StartReturningModel(); err != nil {
		log.Fatalf("Error running program: %s", err)
	} else if err := model.(*Tui).FatalError; err != nil {
		log.Fatal(err)
	}
}
