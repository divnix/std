package main

import (
	"github.com/charmbracelet/bubbles/key"
	"github.com/charmbracelet/bubbles/list"
)

type AppKeyMap struct {
	toggleFocus key.Binding
	forceQuit   key.Binding
}

func NewAppKeyMap() *AppKeyMap {
	return &AppKeyMap{
		// Swiching focus.
		toggleFocus: key.NewBinding(
			key.WithKeys("tab"),
			key.WithHelp("⇥", "toggle focus"),
		),

		// Quitting.
		forceQuit: key.NewBinding(key.WithKeys("ctrl+c")),
	}
}

// DefaultListKeyMap returns a default set of keybindings.
func DefaultListKeyMap() list.KeyMap {
	return list.KeyMap{
		// Browsing.
		CursorUp: key.NewBinding(
			key.WithKeys("up"),
			key.WithHelp("↑", "up"),
		),
		CursorDown: key.NewBinding(
			key.WithKeys("down"),
			key.WithHelp("↓", "down"),
		),
		PrevPage: key.NewBinding(
			key.WithKeys("pgup"),
			key.WithHelp("pgup", "prev page"),
		),
		NextPage: key.NewBinding(
			key.WithKeys("pgdown"),
			key.WithHelp("pgdn", "next page"),
		),
		GoToStart: key.NewBinding(
			key.WithKeys("home"),
			key.WithHelp("home", "go to start"),
		),
		GoToEnd: key.NewBinding(
			key.WithKeys("end"),
			key.WithHelp("end", "go to end"),
		),
		Filter: key.NewBinding(
			key.WithKeys("/"),
			key.WithHelp("/", "filter"),
		),
		ClearFilter: key.NewBinding(
			key.WithKeys("esc"),
			key.WithHelp("esc", "clear filter"),
		),

		// Filtering.
		CancelWhileFiltering: key.NewBinding(
			key.WithKeys("esc"),
			key.WithHelp("esc", "cancel"),
		),
		AcceptWhileFiltering: key.NewBinding(
			key.WithKeys("enter", "tab", "up", "down"),
			key.WithHelp("enter", "apply filter"),
		),

		// Toggle help.
		ShowFullHelp: key.NewBinding(
			key.WithKeys("?"),
			key.WithHelp("?", "more"),
		),
		CloseFullHelp: key.NewBinding(
			key.WithKeys("?"),
			key.WithHelp("?", "close help"),
		),

		// Quitting.
		Quit: key.NewBinding(
			key.WithKeys("q"),
			key.WithHelp("q", "quit"),
		),
		ForceQuit: key.NewBinding(key.WithKeys("ctrl+c")),
	}
}
