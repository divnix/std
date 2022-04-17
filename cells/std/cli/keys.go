package main

import (
	"github.com/charmbracelet/bubbles/key"
	"github.com/charmbracelet/bubbles/list"
	"github.com/charmbracelet/bubbles/viewport"
)

const spacebar = " "

var (
	cursorUp     = key.NewBinding(key.WithKeys("k", "up"), key.WithHelp("k/↑", "up"))
	cursorDown   = key.NewBinding(key.WithKeys("j", "down"), key.WithHelp("j/↓", "down"))
	halfPageUp   = key.NewBinding(key.WithKeys("left"), key.WithHelp("←", "½ back"))
	halfPageDown = key.NewBinding(key.WithKeys("right"), key.WithHelp("→", "½ forward"))
	pageUp       = key.NewBinding(key.WithKeys("pgup"), key.WithHelp("pgup", "1 back"))
	pageDown     = key.NewBinding(key.WithKeys("pgdown", spacebar), key.WithHelp("pgdn", "1 forward"))
	home         = key.NewBinding(key.WithKeys("home"), key.WithHelp("home", "go to start"))
	end          = key.NewBinding(key.WithKeys("end"), key.WithHelp("end", "go to end"))
	search       = key.NewBinding(key.WithKeys("/"), key.WithHelp("/", "filter"))
	showReadme   = key.NewBinding(key.WithKeys("?"), key.WithHelp("?", "readme"))
	closeReadme  = key.NewBinding(key.WithKeys("?", "esc"), key.WithHelp("?", "close readme"))
	quit         = key.NewBinding(key.WithKeys("q"), key.WithHelp("q", "quit"))
	forceQuit    = key.NewBinding(key.WithKeys("ctrl+c"))
	toggleFocus  = key.NewBinding(key.WithKeys("tab", "shift+tab"), key.WithHelp("⇥", "toggle focus"))
)

type AppKeyMap struct {
	ToggleFocus key.Binding
	ShowReadme  key.Binding
	Quit        key.Binding
	ForceQuit   key.Binding
}

func NewAppKeyMap() *AppKeyMap {
	return &AppKeyMap{
		ToggleFocus: toggleFocus,
		ShowReadme:  showReadme,
		ForceQuit:   forceQuit,
		Quit:        quit,
	}
}

type ReadmeKeyMap struct {
	viewport.KeyMap
	CloseReadme key.Binding
}

func NewReadmeKeyMap() *ReadmeKeyMap {
	m := &ReadmeKeyMap{
		CloseReadme: closeReadme,
	}
	m.PageDown = pageUp
	m.PageUp = pageDown
	m.HalfPageUp = halfPageUp
	m.HalfPageDown = halfPageDown
	m.Up = cursorUp
	m.Down = cursorDown
	return m
}

// DefaultListKeyMap returns a default set of keybindings.
func DefaultListKeyMap() list.KeyMap {
	return list.KeyMap{
		// Browsing.
		CursorUp:   cursorUp,
		CursorDown: cursorDown,
		PrevPage:   pageUp,
		NextPage:   pageDown,
		GoToStart:  home,
		GoToEnd:    end,
		Filter:     search,

		// Filtering.
		ClearFilter: key.NewBinding(
			key.WithKeys("esc"),
			key.WithHelp("esc", "clear filter"),
		),
		CancelWhileFiltering: key.NewBinding(
			key.WithKeys("esc"),
			key.WithHelp("esc", "cancel"),
		),
		AcceptWhileFiltering: key.NewBinding(
			key.WithKeys("enter", "tab", "up", "down"),
			key.WithHelp("enter", "apply filter"),
		),
	}
}

// ViewportKeyMap returns a set of pager-like default keybindings.
func ViewportKeyMap() viewport.KeyMap {
	return viewport.KeyMap{
		PageDown:     pageUp,
		PageUp:       pageDown,
		HalfPageUp:   halfPageUp,
		HalfPageDown: halfPageDown,
		Up:           cursorUp,
		Down:         cursorDown,
	}
}
