package main

import (
	"fmt"
	"strings"

	"github.com/charmbracelet/bubbles/help"
	"github.com/charmbracelet/bubbles/key"
	"github.com/charmbracelet/bubbles/list"
	"github.com/charmbracelet/bubbles/spinner"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"

	"github.com/divnix/std/data"
	"github.com/divnix/std/keys"
	"github.com/divnix/std/models"
	"github.com/divnix/std/styles"
)

type Focus int64

const (
	Left Focus = iota
	Right
	Readme
	Inspect
)

const (
	cmdTemplate = "std %s:%s"
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

type Targets = list.Model

type TargetItem struct {
	r            *data.Root
	CellIdx      int
	OrganelleIdx int
	TargetIdx    int
}

func (i TargetItem) Title() string { return i.r.TargetTitle(i.CellIdx, i.OrganelleIdx, i.TargetIdx) }
func (i TargetItem) Description() string {
	return i.r.TargetDescription(i.CellIdx, i.OrganelleIdx, i.TargetIdx)
}
func (i TargetItem) FilterValue() string { return i.Title() }

type Actions = list.Model

type ActionItem struct {
	r            *data.Root
	CellIdx      int
	OrganelleIdx int
	TargetIdx    int
	ActionIdx    int
}

func (i ActionItem) Title() string {
	return i.r.ActionTitle(i.CellIdx, i.OrganelleIdx, i.TargetIdx, i.ActionIdx)
}
func (i ActionItem) Description() string {
	return i.r.ActionDescription(i.CellIdx, i.OrganelleIdx, i.TargetIdx, i.ActionIdx)
}
func (i ActionItem) FilterValue() string { return i.Title() }

type Tui struct {
	r *data.Root

	Left          Targets
	Right         Actions
	Readme        *models.ReadmeModel
	Legend        help.Model
	Keys          *keys.AppKeyMap
	Title         string
	InspectAction string
	ExecveCommand []string
	Spinner       spinner.Model
	Loading       bool
	FatalError    error
	Focus
	Width  int
	Height int
}

func (m *Tui) LoadTargets() tea.Cmd {
	var (
		numItems = m.r.Len()
		counter  = 0
	)
	// Make list of actions
	items := make([]list.Item, numItems)
	for ci, c := range m.r.Cells {
		for oi, o := range c.Organelles {
			for ti, _ := range o.Targets {
				items[counter] = &TargetItem{m.r, ci, oi, ti}
				counter += 1
			}
		}
	}
	cmd := m.Left.SetItems(items)
	if m.Left.SelectedItem() != nil {
		target := m.Left.SelectedItem().(*TargetItem)
		cmd = tea.Batch(cmd, m.LoadActions(target))
	}
	return cmd
}

func (m *Tui) LoadActions(i *TargetItem) tea.Cmd {
	_, _, t := m.r.Select(i.CellIdx, i.OrganelleIdx, i.TargetIdx)
	var numItems = len(t.Actions)
	// Make list of actions
	items := make([]list.Item, numItems)
	for j := 0; j < numItems; j++ {
		items[j] = &ActionItem{m.r, i.CellIdx, i.OrganelleIdx, i.TargetIdx, j}
	}
	return m.Right.SetItems(items)
}

func (m *Tui) SetTitle() {

	if m.Right.SelectedItem() != nil {
		m.Title = fmt.Sprintf(
			cmdTemplate,
			m.Left.SelectedItem().(*TargetItem).Title(),
			m.Right.SelectedItem().(*ActionItem).Title(),
		)
	} else {
		m.Title = lipgloss.NewStyle().Faint(true).Render(fmt.Sprintf(
			cmdTemplate, m.Left.SelectedItem().(*TargetItem).Title(), "n/a",
		))
	}
}

func (m *Tui) SetInspect() (tea.Model, tea.Cmd) {
	if i, ok := m.Right.SelectedItem().(*ActionItem); ok {
		args, msg := m.GetActionCmd(i)
		if msg != nil {
			return m, func() tea.Msg { return msg }
		}
		m.InspectAction = strings.Join(args[:2], " ") +
			" \\\n  " + strings.Join(args[2:4], " ") +
			" \\\n  " + strings.Join(args[4:5], " ") +
			" \\\n  " + strings.Join(args[5:6], " ") +
			" \\\n  " + strings.Join(args[6:7], " ") +
			" \\\n  " + strings.Join(args[7:8], " ") +
			" \\\n  " + args[8]
		return m, nil
	} else {
		m.InspectAction = ""
		return m, nil
	}
}

type cellLoadedMsg = data.Root
type cellLoadingFatalErrMsg struct{ err error }

func (m *Tui) GetActionCmd(i *ActionItem) ([]string, tea.Msg) {
	nix, args, err := GetActionEvalCmdArgs(
		i.r.Cell(i.CellIdx, i.OrganelleIdx, i.TargetIdx),
		i.r.Organelle(i.CellIdx, i.OrganelleIdx, i.TargetIdx),
		i.r.Target(i.CellIdx, i.OrganelleIdx, i.TargetIdx),
		i.r.ActionTitle(i.CellIdx, i.OrganelleIdx, i.TargetIdx, i.ActionIdx),
	)
	if err != nil {
		return nil, cellLoadingFatalErrMsg{err}
	}
	return append([]string{nix}, args...), nil
}

func loadFlake() tea.Msg {
	root, err := LoadFlake()
	if err != nil {
		return cellLoadingFatalErrMsg{err}
	}
	return cellLoadedMsg{root.Cells}
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
	switch msg := msg.(type) {
	case cellLoadedMsg:
		m.r = &msg
		m.Loading = false
		return m, tea.Batch(
			m.LoadTargets(),
			m.Left.StartSpinner(),
		)

	case cellLoadingFatalErrMsg:
		m.FatalError = msg.err
		return m, tea.Quit

	case spinner.TickMsg:
		if m.Loading {
			m.Spinner, cmd = m.Spinner.Update(msg)
			return m, cmd
		}
		m.Left, cmd = m.Left.Update(msg)
		cmds = append(cmds, cmd)
		m.Right, cmd = m.Right.Update(msg)
		cmds = append(cmds, cmd)
		return m, tea.Batch(cmds...)
	case tea.KeyMsg:
		// quit even during filtering
		if key.Matches(msg, m.Keys.ForceQuit) {
			return m, tea.Quit
		}
		// Quit action inspection if enabled.
		if m.Focus == Inspect && key.Matches(msg, actionKeys.QuitInspect) {
			m.Focus = Right
			return m, nil
		}
		// Don't match any of the keys below if we're actively filtering.
		if m.Left.FilterState() == list.Filtering {
			break
		}
		if key.Matches(msg, m.Keys.Quit) {
			return m, tea.Quit
		}
		// Don't match any of the keys below if no target is selected.
		if m.Left.SelectedItem() == nil {
			return m, nil
		}
		switch {
		case m.Focus == Right && key.Matches(msg, actionKeys.Exec):
			if i, ok := m.Right.SelectedItem().(*ActionItem); ok {
				args, msg := m.GetActionCmd(i)
				if msg != nil {
					return m, func() tea.Msg { return msg }
				}
				m.ExecveCommand = args
				return m, tea.Quit
			}
		// toggle the help
		case key.Matches(msg, m.Keys.ShowReadme):
			if m.Focus == Left {
				m.Focus = Readme
				var t = m.Left.SelectedItem().(*TargetItem)
				cmd = m.Readme.RenderMarkdown(m.r, t.CellIdx, t.OrganelleIdx, t.TargetIdx)
				return m, cmd
			}
			if m.Focus == Right {
				m.Focus = Inspect
				return m.SetInspect()
			}
			fallthrough
		case key.Matches(msg, m.Readme.KeyMap.CloseReadme):
			if m.Focus == Readme {
				m.Focus = Left
				m.Readme.CellHelp.SetIsActive(false)
				m.Readme.OrganelleHelp.SetIsActive(false)
				m.Readme.TargetHelp.SetIsActive(false)
				return m, nil
			}

		// toggle the focus
		case key.Matches(msg, m.Keys.ToggleFocus, m.Keys.FocusLeft, m.Keys.FocusRight):
			// Don't toggle the focus if we're showing the help.
			if m.Focus == Readme || m.Focus == Inspect {
				break
			}
			if m.Focus == Left {
				if key.Matches(msg, m.Keys.FocusLeft) {
					return m, nil
				}
				m.Focus = Right
				m.SetTitle()
			} else {
				if key.Matches(msg, m.Keys.FocusRight) {
					return m, nil
				}
				m.Focus = Left
				m.Title = ""
			}
			cmd = m.Left.ToggleSpinner()
			cmds = append(cmds, cmd)
			cmd = m.Right.ToggleSpinner()
			cmds = append(cmds, cmd)
			return m, tea.Batch(cmds...)
		}
	case tea.WindowSizeMsg:
		m.Width = msg.Width
		m.Height = msg.Height
		// size Target
		m.Left.SetHeight(msg.Height - 10)
		m.Left.SetWidth(msg.Width*2/3 - 10)
		// size Action
		m.Right.SetHeight(msg.Height - 10)
		m.Right.SetWidth(msg.Width*1/3 - 10)
		// size Readme
		m.Readme.Height = msg.Height - 10
		m.Readme.Width = msg.Width - 10
		m.Readme, _ = m.Readme.Update(msg)
		return m, nil
	}
	// route all other messages according to state
	if m.Focus == Readme {
		m.Readme, cmd = m.Readme.Update(msg)
		cmds = append(cmds, cmd)
	} else if m.Focus == Left {
		m.Left, cmd = m.Left.Update(msg)
		cmds = append(cmds, cmd)
		if m.Left.SelectedItem() != nil {
			var target = m.Left.SelectedItem().(*TargetItem)
			cmds = append(cmds, m.LoadActions(target))
		} else {
			cmds = append(cmds, m.Right.SetItems([]list.Item{}))
		}
	} else {
		m.Right, cmd = m.Right.Update(msg)
		m.SetTitle()
		cmds = append(cmds, cmd)
		_, cmd = m.SetInspect()
		cmds = append(cmds, cmd)
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
	if m.Focus == Readme {
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

	if m.Focus == Inspect {
		return lipgloss.Place(m.Width, m.Height, lipgloss.Center, lipgloss.Center, styles.
			AppStyle.MaxWidth(m.Width).MaxHeight(m.Height).Render(
			lipgloss.JoinVertical(
				lipgloss.Center,
				title,
				lipgloss.JoinHorizontal(
					lipgloss.Left,
					styles.ActionInspectionStyle.Width(m.Left.Width()).Height(m.Left.Height()).Render(m.InspectAction),
					styles.ActionStyle.Render(m.Right.View()),
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
				styles.TargetStyle.Width(m.Left.Width()).Height(m.Left.Height()).Render(m.Left.View()),
				styles.ActionStyle.Width(m.Right.Width()).Height(m.Right.Height()).Render(m.Right.View()),
			),
			styles.LegendStyle.Render(m.Legend.View(m)),
		)),
	)
}

func (m *Tui) ShortHelp() []key.Binding {
	if m.Focus == Readme {
		return append(m.Readme.ShortHelp(), []key.Binding{
			m.Keys.Quit,
		}...)
	}
	if m.Focus == Left {
		// switch off the list's help
		m.Left.KeyMap.ShowFullHelp.SetEnabled(false)
		m.Left.KeyMap.CloseFullHelp.SetEnabled(false)
		if m.Left.FilterState() == list.Filtering {
			return m.Left.ShortHelp()
		} else {
			return append(m.Left.ShortHelp(), []key.Binding{
				m.Keys.ToggleFocus,
				m.Keys.ShowReadme,
				m.Keys.Quit,
			}...)
		}
	} else {
		// switch off the list's help
		m.Right.KeyMap.ShowFullHelp.SetEnabled(false)
		m.Right.KeyMap.CloseFullHelp.SetEnabled(false)
		return append(m.Right.ShortHelp(), []key.Binding{
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

	spin := spinner.New()
	spin.Spinner = spinner.Points

	return &Tui{
		Left:    InitialTargets(),
		Right:   NewActions(),
		Keys:    keys.NewAppKeyMap(),
		Focus:   Left,
		Readme:  models.NewReadme(),
		Legend:  help.New(),
		Loading: true,
		Spinner: spin,
	}
}

func InitialTargets() Targets {

	targetList := list.New([]list.Item{}, list.NewDefaultDelegate(), 0, 0)
	targetList.Title = "Target"
	targetList.KeyMap = keys.DefaultListKeyMap()
	targetList.SetFilteringEnabled(true)
	targetList.StartSpinner()
	targetList.DisableQuitKeybindings()
	targetList.SetShowHelp(false)

	return targetList
}

func NewActions() Actions {

	newActionDelegate := func(keys *keys.ActionDelegateKeyMap) list.DefaultDelegate {
		d := list.NewDefaultDelegate()

		d.UpdateFunc = func(msg tea.Msg, m *list.Model) tea.Cmd { return nil }

		help := []key.Binding{keys.Exec}
		d.ShortHelpFunc = func() []key.Binding { return help }
		d.FullHelpFunc = func() [][]key.Binding { return [][]key.Binding{} }

		return d
	}

	actionDelegateKeys := keys.NewActionDelegateKeyMap()
	delegate := newActionDelegate(actionDelegateKeys)
	actionList := list.New([]list.Item{}, delegate, 0, 0)
	actionList.Title = fmt.Sprintf("Actions")
	actionList.KeyMap = keys.DefaultListKeyMap()
	actionList.SetShowPagination(false)
	actionList.SetShowHelp(false)
	actionList.SetShowStatusBar(false)
	actionList.SetFilteringEnabled(false)
	actionList.DisableQuitKeybindings()

	return actionList
}
