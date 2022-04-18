package main

import (
	"fmt"

	"math/rand"
	"os"
	"time"

	"github.com/charmbracelet/bubbles/help"
	"github.com/charmbracelet/bubbles/key"
	"github.com/charmbracelet/bubbles/list"
	"github.com/charmbracelet/bubbles/spinner"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

type Focus int64

const (
	Left Focus = iota
	Right
)

const cmdTemplate = "std  %s  %s"

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
	Highlight = lipgloss.AdaptiveColor{Light: "#874BFD", Dark: "#7D56F4"}
	AppStyle  = lipgloss.NewStyle().Padding(1, 2)

	TargetStyle = lipgloss.NewStyle().
			BorderStyle(lipgloss.NormalBorder()).
			BorderForeground(Highlight)

	ActionStyle = lipgloss.NewStyle().
			BorderStyle(lipgloss.NormalBorder()).
			BorderForeground(Highlight)

	ReadmeStyle = lipgloss.NewStyle().
		// BorderStyle(lipgloss.NormalBorder()).
		BorderForeground(Highlight)

	LegendStyle = lipgloss.NewStyle().Padding(1, 0, 0, 2)

	TitleStyle = lipgloss.NewStyle().
			Foreground(Highlight).Bold(true).
			Padding(1, 1)
)

type AppModel struct {
	Target  *TargetModel
	Action  *ActionModel
	Readme  *ReadmeModel
	Keys    *AppKeyMap
	Legend  help.Model
	Title   string
	Spinner spinner.Model
	Loading bool
	Focus
	Width  int
	Height int
}

func (m *AppModel) Init() tea.Cmd {
	return tea.Batch(
		loadFlake,
		tea.EnterAltScreen,
		m.Spinner.Tick,
	)
}

func (m *AppModel) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	var (
		cmds []tea.Cmd
		cmd  tea.Cmd
	)
	// As soon as targets are loaded, stop the loading spinner
	if m.Target.SelectedItem() != nil {
		m.Loading = false
	}
	switch msg := msg.(type) {

	case flakeLoadedMsg:
		m.Target.SetItems(msg.Items)
		return m, nil

	case errMsg:
		return m, tea.Quit

	case spinner.TickMsg:
		if m.Loading {
			m.Spinner, cmd = m.Spinner.Update(msg)
			return m, cmd
		}
		// effectively disables the list-spinners:
		// we're happy with a static vertical line as
		// visual focus clue
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
		case key.Matches(msg, m.Keys.ShowReadme):
			if !m.Readme.Active {
				m.Readme.Active = true
				cmd = m.Readme.RenderMarkdown()
				return m, cmd
			}
		// toggle the focus
		case key.Matches(msg, m.Keys.ToggleFocus):
			// Don't toggle the focus if we're showing the help.
			if m.Readme.Active {
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
		// size Readme
		m.Readme.Height = msg.Height - 10
		m.Readme.Width = msg.Width - 10
		m.Readme, _ = m.Readme.Update(msg)
		return m, nil
	}
	// route all other messages according to state
	if m.Readme.Active {
		m.Readme, cmd = m.Readme.Update(msg)
		cmds = append(cmds, cmd)
	} else if m.Focus == Left {
		m.Target, cmd = m.Target.Update(msg)
		cmds = append(cmds, cmd)
		if m.Target.SelectedItem() != nil {
			var target = m.Target.SelectedItem()
			m.Readme.SetTarget(target)
			m.Action.SetTarget(target)
		} else {
			m.Action.List.SetItems([]list.Item{})
		}
	} else {
		m.Action, cmd = m.Action.Update(msg)
		cmds = append(cmds, cmd)
	}
	// As soon as targets are loaded, change the title
	if m.Target.SelectedItem() != nil {
		m.Title = fmt.Sprintf(cmdTemplate, m.Target.SelectedItem().Title(), m.Action.SelectedItem().Title())
	}
	return m, tea.Batch(cmds...)
}

func (m *AppModel) View() string {
	var title string
	if m.Loading {
		title = TitleStyle.Inline(true).Render("Loading") + "  " + TitleStyle.Inline(true).Render(m.Spinner.View())
	} else {
		title = TitleStyle.Render(m.Title)
	}
	if m.Readme.Active {
		return lipgloss.Place(m.Width, m.Height, lipgloss.Center, lipgloss.Center,
			AppStyle.MaxWidth(m.Width).MaxHeight(m.Height).Render(
				lipgloss.JoinVertical(
					lipgloss.Center,
					title,
					ReadmeStyle.Render(m.Readme.View()),
					LegendStyle.Render(m.Legend.View(m)),
				)),
		)
	}

	return lipgloss.Place(m.Width, m.Height, lipgloss.Center, lipgloss.Center,
		AppStyle.MaxWidth(m.Width).MaxHeight(m.Height).Render(
			lipgloss.JoinVertical(
				lipgloss.Center,
				title,
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
	if m.Readme.Active {
		return append(m.Readme.ShortHelp(), []key.Binding{
			m.Keys.Quit,
		}...)
	}
	if m.Focus == Left {
		if m.Target.List.FilterState() == list.Filtering {
			return m.Target.ShortHelp()
		} else {
			return append(m.Target.ShortHelp(), []key.Binding{
				m.Keys.ToggleFocus,
				m.Keys.ShowReadme,
				m.Keys.Quit,
			}...)
		}
	} else {
		return append(m.Action.ShortHelp(), []key.Binding{
			m.Keys.ToggleFocus,
			m.Keys.ShowReadme,
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
	action := NewAction()
	spin := spinner.New()
	spin.Spinner = spinner.Points
	return &AppModel{
		Target:  target,
		Action:  action,
		Keys:    NewAppKeyMap(),
		Focus:   Left,
		Readme:  NewReadme(),
		Legend:  help.New(),
		Loading: true,
		Spinner: spin,
	}
}

func main() {
	rand.Seed(time.Now().UTC().UnixNano())

	if err := tea.NewProgram(InitialPage()).Start(); err != nil {
		fmt.Println("Error running program:", err)
		os.Exit(1)
	}
}
