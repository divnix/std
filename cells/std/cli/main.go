package main

import (
	"fmt"

	"math/rand"
	"os"
	"time"

	"github.com/charmbracelet/bubbles/help"
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

	HelpStyle = lipgloss.NewStyle().
			BorderStyle(lipgloss.NormalBorder()).
			BorderForeground(lipgloss.AdaptiveColor{Light: "63", Dark: "63"})

	LegendStyle = lipgloss.NewStyle().Padding(1, 0, 0, 2)

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
	Help   *HelpModel
	Keys   *AppKeyMap
	Legend help.Model
	Focus
	Width  int
	Height int
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
		if key.Matches(msg, m.Keys.ForceQuit) {
			return m, tea.Quit
		}
		// Don't match any of the keys below if we're actively filtering.
		if m.Target.List.FilterState() == list.Filtering {
			break
		}
		if key.Matches(msg, m.Keys.Quit) {
			return m, tea.Quit
		}
		// Don't match any of the keys below if no target is selected.
		if m.Target.SelectedItem() == nil {
			return m, nil
		}
		switch {
		// toggle the help
		case key.Matches(msg, m.Keys.ShowHelp):
			// set here to ignore if unselected
			if !m.Help.Active {
				m.Help.Active = true
				cmd = m.Help.RenderMarkdown()
				return m, cmd
			}
		// toggle the focus
		case key.Matches(msg, m.Keys.ToggleFocus):
			// Don't toggle the focus if we're showing the help.
			if m.Help.Active {
				break
			}
			if m.Focus == Left {
				m.Focus = Right
			} else {
				m.Focus = Left
			}
			m.Target, cmd = m.Target.Update(msg)
			cmds = append(cmds, cmd)
			m.Action, cmd = m.Action.Update(msg)
			cmds = append(cmds, cmd)
			return m, tea.Batch(cmds...)
		}
	case tea.WindowSizeMsg:
		m.Width = msg.Width
		m.Height = msg.Height
		// size Target
		m.Target.Height = msg.Height - 10
		m.Target.Width = msg.Width*2/3 - 10
		m.Target, _ = m.Target.Update(msg)
		// size Action
		m.Action.Height = msg.Height - 10
		m.Action.Width = msg.Width*1/3 - 10
		m.Action, _ = m.Action.Update(msg)
		// size Help
		m.Help.Height = msg.Height - 10
		m.Help.Width = msg.Width - 20
		m.Help, _ = m.Help.Update(msg)
		return m, nil
	}
	// route all other messages according to state
	if m.Help.Active {
		m.Help, cmd = m.Help.Update(msg)
		cmds = append(cmds, cmd)
	} else if m.Focus == Left {
		m.Target, cmd = m.Target.Update(msg)
		cmds = append(cmds, cmd)
		if m.Target.SelectedItem() != nil {
			var target = m.Target.SelectedItem()
			m.Help.SetTarget(target)
			m.Action.SetTarget(target)
		} else {
			m.Action.List.SetItems([]list.Item{})
		}
	} else {
		m.Action, cmd = m.Action.Update(msg)
		cmds = append(cmds, cmd)
	}

	return m, tea.Batch(cmds...)
}

func (m *AppModel) View() string {
	if m.Help.Active {
		return lipgloss.Place(m.Width, m.Height, lipgloss.Center, lipgloss.Center,
			AppStyle.MaxWidth(m.Width).MaxHeight(m.Height).Render(
				lipgloss.JoinVertical(
					lipgloss.Center,
					HelpStyle.Render(m.Help.View()),
					LegendStyle.Render(m.Legend.View(m)),
				)),
		)
	}

	return lipgloss.Place(m.Width, m.Height, lipgloss.Center, lipgloss.Center,
		AppStyle.MaxWidth(m.Width).MaxHeight(m.Height).Render(
			lipgloss.JoinVertical(
				lipgloss.Center,
				lipgloss.JoinHorizontal(
					lipgloss.Left,
					TargetStyle.Render(m.Target.View()),
					ActionStyle.Render(m.Action.View()),
				),
				LegendStyle.Render(m.Legend.View(m)),
			)),
	)
}

func (m *AppModel) ShortHelp() []key.Binding {
	if m.Help.Active {
		return append(m.Help.ShortHelp(), []key.Binding{
			m.Keys.Quit,
		}...)
	}
	if m.Focus == Left {
		if m.Target.List.FilterState() == list.Filtering {
			return m.Target.ShortHelp()
		} else {
			return append(m.Target.ShortHelp(), []key.Binding{
				m.Keys.ToggleFocus,
				m.Keys.ShowHelp,
				m.Keys.Quit,
			}...)
		}
	} else {
		return append(m.Action.ShortHelp(), []key.Binding{
			m.Keys.ToggleFocus,
			m.Keys.ShowHelp,
			m.Keys.Quit,
		}...)
	}
}

func (m *AppModel) FullHelp() [][]key.Binding {
	kb := [][]key.Binding{{}}
	return kb
}

func InitialPage() *AppModel {
	target := InitialTarget()
	action := NewAction(target.List.SelectedItem().(item))
	return &AppModel{
		Target: target,
		Action: action,
		Keys:   NewAppKeyMap(),
		Focus:  Left,
		Help:   NewHelp(),
		Legend: help.New(),
	}
}

func main() {
	rand.Seed(time.Now().UTC().UnixNano())

	if err := tea.NewProgram(InitialPage()).Start(); err != nil {
		fmt.Println("Error running program:", err)
		os.Exit(1)
	}
}
