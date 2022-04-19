package keys

import (
	"github.com/charmbracelet/bubbles/key"
	"github.com/charmbracelet/bubbles/list"
	"github.com/charmbracelet/bubbles/viewport"
)

const spacebar = " "

var (
	cursorUp        = key.NewBinding(key.WithKeys("k", "up"), key.WithHelp("k/↑", "up"))
	cursorDown      = key.NewBinding(key.WithKeys("j", "down"), key.WithHelp("j/↓", "down"))
	cursorLeft      = key.NewBinding(key.WithKeys("left"), key.WithHelp("←", "½ back"))
	cursorRight     = key.NewBinding(key.WithKeys("right"), key.WithHelp("→", "½ forward"))
	pageUp          = key.NewBinding(key.WithKeys("pgup"), key.WithHelp("pgup", "1 back"))
	pageDown        = key.NewBinding(key.WithKeys("pgdown", spacebar), key.WithHelp("pgdn", "1 forward"))
	home            = key.NewBinding(key.WithKeys("home"), key.WithHelp("home", "go to start"))
	end             = key.NewBinding(key.WithKeys("end"), key.WithHelp("end", "go to end"))
	enter           = key.NewBinding(key.WithKeys("enter"), key.WithHelp("⏎", "execute"))
	search          = key.NewBinding(key.WithKeys("/"), key.WithHelp("/", "filter"))
	showReadme      = key.NewBinding(key.WithKeys("?"), key.WithHelp("?", "inspect"))
	closeReadme     = key.NewBinding(key.WithKeys("?", "esc"), key.WithHelp("?", "close"))
	quit            = key.NewBinding(key.WithKeys("q"), key.WithHelp("q", "quit"))
	forceQuit       = key.NewBinding(key.WithKeys("ctrl+c"))
	toggleFocus     = key.NewBinding(key.WithKeys("tab", "shift+tab"), key.WithHelp("⇥", "toggle focus"))
	cycleTab        = key.NewBinding(key.WithKeys("tab"), key.WithHelp("⇥", "cycle tabs"))
	reverseCycleTab = key.NewBinding(key.WithKeys("shift+tab"))
)

type AppKeyMap struct {
	ToggleFocus key.Binding
	FocusLeft   key.Binding
	FocusRight  key.Binding
	ShowReadme  key.Binding
	Quit        key.Binding
	ForceQuit   key.Binding
}

func NewAppKeyMap() *AppKeyMap {
	return &AppKeyMap{
		ToggleFocus: toggleFocus,
		FocusLeft:   cursorLeft,
		FocusRight:  cursorRight,
		ShowReadme:  showReadme,
		ForceQuit:   forceQuit,
		Quit:        quit,
	}
}

type ReadmeKeyMap struct {
	viewport.KeyMap
	CloseReadme     key.Binding
	CycleTab        key.Binding
	ReverseCycleTab key.Binding
}

func NewReadmeKeyMap() *ReadmeKeyMap {
	m := &ReadmeKeyMap{
		CloseReadme:     closeReadme,
		CycleTab:        cycleTab,
		ReverseCycleTab: reverseCycleTab,
	}
	m.PageDown = pageUp
	m.PageUp = pageDown
	m.HalfPageUp = cursorLeft
	m.HalfPageDown = cursorRight
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

type ActionDelegateKeyMap struct {
	Exec        key.Binding
	Inspect     key.Binding
	QuitInspect key.Binding
}

// Additional short help entries. This satisfies the help.KeyMap interface and
// is entirely optional.
func (d ActionDelegateKeyMap) ShortHelp() []key.Binding {
	return []key.Binding{
		d.Exec,
		d.Inspect,
		d.QuitInspect,
	}
}

func NewActionDelegateKeyMap() *ActionDelegateKeyMap {
	return &ActionDelegateKeyMap{
		Exec:        enter,
		Inspect:     showReadme,
		QuitInspect: closeReadme,
	}
}

// ViewportKeyMap returns a set of pager-like default keybindings.
func ViewportKeyMap() viewport.KeyMap {
	return viewport.KeyMap{
		PageDown:     pageUp,
		PageUp:       pageDown,
		HalfPageUp:   cursorLeft,
		HalfPageDown: cursorRight,
		Up:           cursorUp,
		Down:         cursorDown,
	}
}
