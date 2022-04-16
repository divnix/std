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

	TargetStyle = lipgloss.NewStyle().
			BorderStyle(lipgloss.NormalBorder()).
			BorderForeground(lipgloss.Color("63"))

	ActionStyle = lipgloss.NewStyle().
			BorderStyle(lipgloss.NormalBorder()).
			BorderForeground(lipgloss.Color("63"))

	// TitleStyle = lipgloss.NewStyle().
	// 		Foreground(lipgloss.Color("#FFFDF5")).
	// 		Background(lipgloss.Color("#25A065")).
	// 		Padding(0, 1)

	// StatusMessageStyle = lipgloss.NewStyle().
	// 			Foreground(lipgloss.AdaptiveColor{Light: "#04B575", Dark: "#04B575"}).
	// 			Render
)

type AppModel struct {
	Target *TargetModel
	Action *ActionModel
	Keys   *AppKeyMap
	Focus
	FullHelp bool
	Width    int
	Height   int
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
		case key.Matches(msg, m.Keys.toggleHelp):
			m.FullHelp = !m.FullHelp
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
		}
	case tea.WindowSizeMsg:
		m.Width = msg.Width
		m.Height = msg.Height
		m.Target.Height = msg.Height - 10
		m.Target.Width = msg.Width*2/3 - 10
		m.Action.Height = msg.Height - 10
		m.Action.Width = msg.Width*1/3 - 10
		m.Target.List.SetHeight(m.Target.Height)
		m.Target.List.SetWidth(m.Target.Width)
		m.Action.List.SetHeight(m.Action.Height)
		m.Action.List.SetWidth(m.Action.Width)
		return m, nil
	}

	// This will also call our delegate's update function.
	if m.Focus == Left {
		m.Target, cmd = m.Target.Update(msg)
		if m.Target.List.SelectedItem() != nil {
			var (
				target   = m.Target.List.SelectedItem().(item)
				numItems = cap(target.actions)
			)
			// Make list of actions
			items := make([]list.Item, numItems)
			for j := 0; j < numItems; j++ {
				items[j] = target.actions[j]
			}
			m.Action.List.Title = fmt.Sprintf("Actions for %s", target.StdClade)
			m.Action.List.SetItems(items)
		} else {
			m.Action.List.SetItems([]list.Item{})
		}
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

	if m.FullHelp {
		return lipgloss.Place(m.Width, m.Height, lipgloss.Center, lipgloss.Center,
			lipgloss.NewStyle().Border(lipgloss.NormalBorder()).Padding(1, 2).Render("Help"),
		)
	}

	return lipgloss.Place(m.Width, m.Height, lipgloss.Center, lipgloss.Center,
		AppStyle.MaxWidth(m.Width).MaxHeight(m.Height).Render(
			lipgloss.JoinVertical(
				lipgloss.Center,
				lipgloss.JoinHorizontal(
					lipgloss.Left,
					TargetStyle.Width(m.Target.Width).Height(m.Target.Height).Render(m.Target.View()),
					ActionStyle.Width(m.Action.Width).Height(m.Action.Height).Render(m.Action.View()),
				),
				help,
			)),
	)
}

func InitialPage() *AppModel {
	target := InitialTarget()
	action := NewAction(target.List.SelectedItem().(item))
	return &AppModel{
		Target:   target,
		Action:   action,
		Keys:     NewAppKeyMap(),
		Focus:    Left,
		FullHelp: false,
	}
}

func main() {
	rand.Seed(time.Now().UTC().UnixNano())

	if err := tea.NewProgram(InitialPage()).Start(); err != nil {
		fmt.Println("Error running program:", err)
		os.Exit(1)
	}
}
