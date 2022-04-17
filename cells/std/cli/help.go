package main

import (
	"fmt"

	"github.com/charmbracelet/bubbles/help"
	"github.com/charmbracelet/bubbles/key"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
	"github.com/knipferrc/teacup/markdown"
)

const (
	noTargetReadme = `Target '%s' has no readme yet.

To create one, simply drop a file in:

  ${cellsFrom}/%s/%s/%s.md
`
	noCellReadme = `Cell '%s' has no readme yet.

To create one, simply drop a file in:

  ${cellsFrom}/%s/Readme.md
`
	noOrganelleReadme = `Organelle '%s/%s' has no readme yet.

To create one, simply drop a file in:

  ${cellsFrom}/%s/%s/Reame.md
`
)

type HelpModel struct {
	Target           *item
	TargetHelp       markdown.Bubble
	CellHelp         markdown.Bubble
	OrganelleHelp    markdown.Bubble
	HasTargetHelp    bool
	HasCellHelp      bool
	HasOrganelleHelp bool
	Active           bool
	Width            int
	Height           int
	KeyMap           *HelpKeyMap
	Help             help.Model
	// Focus
}

func (m *HelpModel) SetTarget(t *item) {
	m.Target = t
	m.HasTargetHelp = t.StdReadme != ""
	m.HasCellHelp = false
	m.HasOrganelleHelp = false
	if m.HasTargetHelp {
		m.TargetHelp.Viewport.SetContent(fmt.Sprintf("Rendering %s ...", t.StdReadme))
	} else {
		content := lipgloss.NewStyle().
			Width(m.Width).
			Height(m.Height).
			Render(fmt.Sprintf(noTargetReadme, t.Title(), t.StdCell, t.StdOrganelle, t.StdName))
		m.TargetHelp.Viewport.SetContent(content)
	}
	if m.HasCellHelp {
		m.CellHelp.Viewport.SetContent(fmt.Sprintf("Rendering %s ...", "TODO-CELL"))
	} else {
		content := lipgloss.NewStyle().
			Width(m.Width).
			Height(m.Height).
			Render(fmt.Sprintf(noCellReadme, t.StdCell, t.StdCell))
		m.CellHelp.Viewport.SetContent(content)
	}
	if m.HasOrganelleHelp {
		m.OrganelleHelp.Viewport.SetContent(fmt.Sprintf("Rendering %s ...", "TODO-ORGANELLE"))
	} else {
		content := lipgloss.NewStyle().
			Width(m.Width).
			Height(m.Height).
			Render(fmt.Sprintf(noOrganelleReadme, t.StdCell, t.StdOrganelle, t.StdCell, t.StdOrganelle))
		m.OrganelleHelp.Viewport.SetContent(content)
	}
}

func NewHelp() *HelpModel {
	var (
		th = markdown.New(false, true, lipgloss.AdaptiveColor{})
		ch = markdown.New(false, true, lipgloss.AdaptiveColor{})
		oh = markdown.New(false, true, lipgloss.AdaptiveColor{})
	)
	th.Viewport.KeyMap = ViewportKeyMap()
	ch.Viewport.KeyMap = ViewportKeyMap()
	oh.Viewport.KeyMap = ViewportKeyMap()
	return &HelpModel{
		TargetHelp:    th,
		CellHelp:      ch,
		OrganelleHelp: oh,
		Help:          help.New(),
		KeyMap:        NewHelpKeyMap(),
	}
}
func (m *HelpModel) Init() tea.Cmd {
	return nil
}

func (m *HelpModel) RenderMarkdown() tea.Cmd {
	var (
		cmds []tea.Cmd
		cmd  tea.Cmd
	)
	m.TargetHelp.SetIsActive(true)
	if m.HasTargetHelp {
		cmd = m.TargetHelp.SetFileName(m.Target.StdReadme)
		cmds = append(cmds, cmd)
	}
	if m.HasCellHelp {
		cmd = m.CellHelp.SetFileName(m.Target.StdReadme)
		cmds = append(cmds, cmd)
	}
	if m.HasOrganelleHelp {
		cmd = m.OrganelleHelp.SetFileName(m.Target.StdReadme)
		cmds = append(cmds, cmd)
	}
	return tea.Batch(cmds...)
}

func (m *HelpModel) Update(msg tea.Msg) (*HelpModel, tea.Cmd) {
	var (
		cmd tea.Cmd
	)
	switch msg := msg.(type) {
	case tea.KeyMsg:
		switch {
		// activate and deactivate help
		// ShowHelp shadows CloseHelp in case of the toggle key '?'
		case key.Matches(msg, m.KeyMap.CloseHelp):
			m.Active = false
			m.TargetHelp.SetIsActive(false)
			return m, nil
		}
	case tea.WindowSizeMsg:
		m.TargetHelp.SetSize(m.Width, m.Height)
	}
	m.TargetHelp, cmd = m.TargetHelp.Update(msg)
	return m, cmd
}

func (m *HelpModel) View() string {
	return m.TargetHelp.View()
}

func (m *HelpModel) ShortHelp() []key.Binding {
	kb := []key.Binding{
		m.KeyMap.Up,
		m.KeyMap.Down,
		m.KeyMap.HalfPageUp,
		m.KeyMap.HalfPageDown,
		m.KeyMap.CloseHelp,
	}
	return kb
}

func (m *HelpModel) FullHelp() [][]key.Binding {
	kb := [][]key.Binding{{}}
	return kb
}
