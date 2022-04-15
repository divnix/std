package main

import (
	"fmt"

	"math/rand"
	"os"
	"time"

	"github.com/charmbracelet/bubbles/key"
	"github.com/charmbracelet/bubbles/list"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

type Focus int64

const (
	Left Focus = iota
	Right
)

func (s Focus) String() string {
	switch s {
	case Left:
		return "left focus"
	case Right:
		return "right focus"
	}
	return "unknown"
}

var (
	AppStyle = lipgloss.NewStyle().
			BorderForeground(lipgloss.Color("63")).
			Padding(1, 2)

	TitleStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color("#FFFDF5")).
			Background(lipgloss.Color("#25A065")).
			Padding(0, 1)

	StatusMessageStyle = lipgloss.NewStyle().
				Foreground(lipgloss.AdaptiveColor{Light: "#04B575", Dark: "#04B575"}).
				Render
)

type AppModel struct {
	Target *TargetModel
	Action *ActionModel
	Keys   *AppKeyMap
	Focus
}

func (m *AppModel) Init() tea.Cmd {
	return tea.EnterAltScreen
}
func (m *AppModel) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	var (
		cmds []tea.Cmd
		cmd  tea.Cmd
	)
	switch msg := msg.(type) {
	case tea.KeyMsg:
		// quit even during filtering
		if key.Matches(msg, m.Keys.forceQuit) {
			return m, tea.Quit
		}
		// Don't match any of the keys below if we're actively filtering.
		if m.Target.List.FilterState() == list.Filtering {
			break
		}
		switch {
		case key.Matches(msg, m.Keys.toggleFocus):
			if m.Focus == Left {
				m.Focus = Right
				cmd = m.Target.List.ToggleSpinner()
				cmds = append(cmds, cmd)
				cmd = m.Action.List.ToggleSpinner()
				cmds = append(cmds, cmd)
			} else {
				m.Focus = Left
				cmd = m.Target.List.ToggleSpinner()
				cmds = append(cmds, cmd)
				cmd = m.Action.List.ToggleSpinner()
				cmds = append(cmds, cmd)
			}
			return m, tea.Batch(cmds...)
		}
	case tea.WindowSizeMsg:
	}

	// This will also call our delegate's update function.
	if m.Focus == Left {
		m.Target, cmd = m.Target.Update(msg)
		m.Action = NewAction(m.Target.List.SelectedItem().(item))
		cmds = append(cmds, cmd)
	} else {
		m.Action, cmd = m.Action.Update(msg)
		cmds = append(cmds, cmd)
	}

	return m, tea.Batch(cmds...)
}
func (m *AppModel) View() string {
	var help string
	if m.Focus == Left {
		var l = m.Target.List
		help = l.Styles.HelpStyle.Render(l.Help.View(l))
	} else {
		var l = m.Action.List
		help = l.Styles.HelpStyle.Render(l.Help.View(l))
	}
	return AppStyle.Render(
		lipgloss.JoinVertical(
			lipgloss.Center,
			lipgloss.JoinHorizontal(lipgloss.Left, m.Target.View(), m.Action.View()),
			help,
		))
}

func InitialPage() *AppModel {
	targets := InitialTarget()
	action := NewAction(targets.List.SelectedItem().(item))
	self := &AppModel{targets, action, NewAppKeyMap(), Left}
	return self
}

func main() {
	rand.Seed(time.Now().UTC().UnixNano())

	if err := tea.NewProgram(InitialPage()).Start(); err != nil {
		fmt.Println("Error running program:", err)
		os.Exit(1)
	}
}
