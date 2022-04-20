package main

import (
	"fmt"

	"github.com/charmbracelet/bubbles/help"
	"github.com/charmbracelet/bubbles/key"
	"github.com/charmbracelet/bubbles/list"
	"github.com/charmbracelet/bubbles/spinner"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"

	"github.com/divnix/std/keys"
	"github.com/divnix/std/models"
	"github.com/divnix/std/styles"
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

type Tui struct {
	Target       *models.TargetModel
	Action       *models.ActionModel
	Readme       *models.ReadmeModel
	Keys         *keys.AppKeyMap
	Legend       help.Model
	Title        string
	InspecAction string
	Spinner      spinner.Model
	Loading      bool
	Error        string
	Focus
	Width  int
	Height int
}

func (m *Tui) Init() tea.Cmd {
	return tea.Batch(
		loadFlake,
		tea.EnterAltScreen,
		m.Spinner.Tick,
	)
}

func (m *Tui) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	var (
		cmds       []tea.Cmd
		cmd        tea.Cmd
		actionKeys = keys.NewActionDelegateKeyMap()
	)
	// As soon as targets are loaded, stop the loading spinner
	if m.Target.SelectedItem() != nil {
		m.Loading = false
	}
	switch msg := msg.(type) {
	case flakeLoadedMsg:
		m.Target.SetItems(msg.Items)
		return m, nil

	case exitErrMsg:
		m.Error = msg.Error()
		return m, nil

	case models.ActionInspectMsg:
		m.InspecAction = string(msg)
		return m, nil

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
		// Quit action inspection if enabled.
		if m.InspecAction != "" && key.Matches(msg, actionKeys.QuitInspect) {
			m.InspecAction = ""
			return m, nil
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
			if m.Focus == Left {
				if !m.Readme.Active {
					m.Readme.Active = true
					cmd = m.Readme.RenderMarkdown()
					return m, cmd
				}
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
		case key.Matches(msg, m.Keys.FocusLeft):
			// Don't toggle the focus if we're showing the help.
			if m.Readme.Active {
				break
			}
			if m.Focus != Left {
				m.Focus = Left
				m.Target, cmd = m.Target.Update(msg)
				cmds = append(cmds, cmd)
				m.Action, cmd = m.Action.Update(msg)
				cmds = append(cmds, cmd)
			}
			return m, tea.Batch(cmds...)
		case key.Matches(msg, m.Keys.FocusRight):
			// Don't toggle the focus if we're showing the help.
			if m.Readme.Active {
				break
			}
			if m.Focus != Right {
				m.Focus = Right
				m.Target, cmd = m.Target.Update(msg)
				cmds = append(cmds, cmd)
				m.Action, cmd = m.Action.Update(msg)
				cmds = append(cmds, cmd)
			}
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
		if m.Action.SelectedItem() != nil {
			m.Title = fmt.Sprintf(cmdTemplate, m.Target.SelectedItem().Title(), m.Action.SelectedItem().Title())
		} else {
			m.Title = lipgloss.NewStyle().Faint(true).Render(fmt.Sprintf(cmdTemplate, m.Target.SelectedItem().Title(), "n/a"))
		}
	}
	return m, tea.Batch(cmds...)
}

func (m *Tui) View() string {
	var title string
	if m.Loading {
		title = styles.TitleStyle.Render("Loading  " + m.Spinner.View())
	} else {
		title = styles.TitleStyle.Render(m.Title)
	}
	if m.Readme.Active {
		return lipgloss.Place(m.Width, m.Height, lipgloss.Center, lipgloss.Center,
			styles.AppStyle.MaxWidth(m.Width).MaxHeight(m.Height).Render(
				lipgloss.JoinVertical(
					lipgloss.Center,
					title,
					styles.ReadmeStyle.Render(m.Readme.View()),
					styles.LegendStyle.Render(m.Legend.View(m)),
				)),
		)
	}

	if m.Error != "" {
		return lipgloss.Place(m.Width, m.Height, lipgloss.Center, lipgloss.Center, styles.
			AppStyle.MaxWidth(m.Width).MaxHeight(m.Height).Render(
			lipgloss.JoinVertical(
				lipgloss.Center,
				title,
				styles.ErrorStyle.Width(m.Width-10).Height(m.Height-10).Render(m.Error),
				styles.LegendStyle.Render(m.Legend.View(m)),
			)),
		)
	}
	if m.InspecAction != "" {
		return lipgloss.Place(m.Width, m.Height, lipgloss.Center, lipgloss.Center, styles.
			AppStyle.MaxWidth(m.Width).MaxHeight(m.Height).Render(
			lipgloss.JoinVertical(
				lipgloss.Center,
				title,
				lipgloss.JoinHorizontal(
					lipgloss.Left,
					styles.ActionInspectionStyle.Width(m.Target.Width).Height(m.Target.Height).Render(m.InspecAction),
					styles.ActionStyle.Render(m.Action.View()),
				),
				styles.LegendStyle.Render(m.Legend.View(m)),
			)),
		)
	}

	return lipgloss.Place(m.Width, m.Height, lipgloss.Center, lipgloss.Center, styles.
		AppStyle.MaxWidth(m.Width).MaxHeight(m.Height).Render(
		lipgloss.JoinVertical(
			lipgloss.Center,
			title,
			lipgloss.JoinHorizontal(
				lipgloss.Left,
				styles.TargetStyle.Width(m.Target.Width).Height(m.Target.Height).Render(m.Target.View()),
				styles.ActionStyle.Render(m.Action.View()),
			),
			styles.LegendStyle.Render(m.Legend.View(m)),
		)),
	)
}

func (m *Tui) ShortHelp() []key.Binding {
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

func (m *Tui) FullHelp() [][]key.Binding {
	kb := [][]key.Binding{{}}
	return kb
}

func InitialPage() *Tui {

	target := models.InitialTarget()
	action := models.NewAction()
	spin := spinner.New()
	spin.Spinner = spinner.Points

	return &Tui{
		Target:  target,
		Action:  action,
		Keys:    keys.NewAppKeyMap(),
		Focus:   Left,
		Readme:  models.NewReadme(),
		Legend:  help.New(),
		Loading: true,
		Spinner: spin,
	}
}
