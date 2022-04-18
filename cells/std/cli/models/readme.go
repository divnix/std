package models

import (
	"fmt"
	"strings"

	"github.com/charmbracelet/bubbles/help"
	"github.com/charmbracelet/bubbles/key"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
	"github.com/knipferrc/teacup/markdown"

	"github.com/divnix/std/cells/std/cli/data"
	"github.com/divnix/std/cells/std/cli/keys"
	"github.com/divnix/std/cells/std/cli/styles"
)

const (
	noTargetReadme = `Target '%s' has no readme yet.

To create one, simply drop a file in:

  ${cellsFrom}/%s/%s/%s.md
`
	noCellReadme = `Cell '//%s' has no readme yet.

To create one, simply drop a file in:

  ${cellsFrom}/%s/Readme.md
`
	noOrganelleReadme = `Organelle '//%s/%s' has no readme yet.

To create one, simply drop a file in:

  ${cellsFrom}/%s/%s/Readme.md
`
)

var (

	// Tabs.

	activeTabBorder = lipgloss.Border{
		Top:         "─",
		Bottom:      " ",
		Left:        "│",
		Right:       "│",
		TopLeft:     "╭",
		TopRight:    "╮",
		BottomLeft:  "┘",
		BottomRight: "└",
	}

	tabBorder = lipgloss.Border{
		Top:         "─",
		Bottom:      "─",
		Left:        "│",
		Right:       "│",
		TopLeft:     "╭",
		TopRight:    "╮",
		BottomLeft:  "┴",
		BottomRight: "┴",
	}

	tab = lipgloss.NewStyle().
		Border(tabBorder, true).
		BorderForeground(styles.Highlight).
		Padding(0, 1)

	activeTab = tab.Copy().Border(activeTabBorder, true)

	tabGap = tab.Copy().
		BorderTop(false).
		BorderLeft(false).
		BorderRight(false)
)

type ReadmeModel struct {
	Target           *data.Item
	TargetHelp       markdown.Bubble
	CellHelp         markdown.Bubble
	OrganelleHelp    markdown.Bubble
	HasTargetHelp    bool
	HasCellHelp      bool
	HasOrganelleHelp bool
	Active           bool
	Width            int
	Height           int
	KeyMap           *keys.ReadmeKeyMap
	Help             help.Model
	// Focus
}

type renderCellMarkdownMsg struct {
	msg tea.Msg
}
type renderOrganelleMarkdownMsg struct {
	msg tea.Msg
}
type renderTargetMarkdownMsg struct {
	msg tea.Msg
}

func (m *ReadmeModel) SetTarget(t *data.Item) {
	m.Target = t
	m.HasTargetHelp = t.StdReadme != ""
	m.HasCellHelp = t.StdCellReadme != ""
	m.HasOrganelleHelp = t.StdOrganelleReadme != ""
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
		m.CellHelp.Viewport.SetContent(fmt.Sprintf("Rendering %s ...", t.StdCellReadme))
	} else {
		content := lipgloss.NewStyle().
			Width(m.Width).
			Height(m.Height).
			Render(fmt.Sprintf(noCellReadme, t.StdCell, t.StdCell))
		m.CellHelp.Viewport.SetContent(content)
	}
	if m.HasOrganelleHelp {
		m.OrganelleHelp.Viewport.SetContent(fmt.Sprintf("Rendering %s ...", t.StdOrganelleReadme))
	} else {
		content := lipgloss.NewStyle().
			Width(m.Width).
			Height(m.Height).
			Render(fmt.Sprintf(noOrganelleReadme, t.StdCell, t.StdOrganelle, t.StdCell, t.StdOrganelle))
		m.OrganelleHelp.Viewport.SetContent(content)
	}
}

func NewReadme() *ReadmeModel {
	var (
		th = markdown.New(false, true, lipgloss.AdaptiveColor{})
		ch = markdown.New(false, true, lipgloss.AdaptiveColor{})
		oh = markdown.New(false, true, lipgloss.AdaptiveColor{})
	)
	th.Viewport.KeyMap = keys.ViewportKeyMap()
	ch.Viewport.KeyMap = keys.ViewportKeyMap()
	oh.Viewport.KeyMap = keys.ViewportKeyMap()
	return &ReadmeModel{
		TargetHelp:    th,
		CellHelp:      ch,
		OrganelleHelp: oh,
		Help:          help.New(),
		KeyMap:        keys.NewReadmeKeyMap(),
	}
}
func (m *ReadmeModel) Init() tea.Cmd {
	return nil
}

func (m *ReadmeModel) RenderMarkdown() tea.Cmd {
	var (
		cmds []tea.Cmd
		cmd  tea.Cmd
	)
	m.TargetHelp.SetIsActive(true)
	if m.HasCellHelp {
		cmd = func() tea.Msg {
			return renderCellMarkdownMsg{m.CellHelp.SetFileName(m.Target.StdCellReadme)()}
		}
		cmds = append(cmds, cmd)
	}
	if m.HasOrganelleHelp {
		cmd = func() tea.Msg {
			return renderOrganelleMarkdownMsg{m.OrganelleHelp.SetFileName(m.Target.StdOrganelleReadme)()}
		}
		cmds = append(cmds, cmd)
	}
	if m.HasTargetHelp {
		cmd = func() tea.Msg {
			return renderTargetMarkdownMsg{m.TargetHelp.SetFileName(m.Target.StdReadme)()}
		}
		cmds = append(cmds, cmd)
	}
	return tea.Batch(cmds...)
}

func (m *ReadmeModel) Update(msg tea.Msg) (*ReadmeModel, tea.Cmd) {
	var (
		cmd tea.Cmd
	)
	switch msg := msg.(type) {
	case tea.KeyMsg:
		switch {
		// activate and deactivate help
		// ShowHelp shadows CloseHelp in case of the toggle key '?'
		case key.Matches(msg, m.KeyMap.CloseReadme):
			m.Active = false
			m.CellHelp.SetIsActive(false)
			m.OrganelleHelp.SetIsActive(false)
			m.TargetHelp.SetIsActive(false)
			return m, nil
		case key.Matches(msg, m.KeyMap.CycleTab):
			if m.TargetHelp.Active {
				m.TargetHelp.SetIsActive(false)
				m.CellHelp.SetIsActive(true)
			} else if m.CellHelp.Active {
				m.CellHelp.SetIsActive(false)
				m.OrganelleHelp.SetIsActive(true)
			} else if m.OrganelleHelp.Active {
				m.OrganelleHelp.SetIsActive(false)
				m.TargetHelp.SetIsActive(true)
			}
			return m, nil
		case key.Matches(msg, m.KeyMap.ReverseCycleTab):
			if m.TargetHelp.Active {
				m.TargetHelp.SetIsActive(false)
				m.OrganelleHelp.SetIsActive(true)
			} else if m.CellHelp.Active {
				m.CellHelp.SetIsActive(false)
				m.TargetHelp.SetIsActive(true)
			} else if m.OrganelleHelp.Active {
				m.OrganelleHelp.SetIsActive(false)
				m.CellHelp.SetIsActive(true)
			}
			return m, nil
		}
	case tea.WindowSizeMsg:
		m.CellHelp.SetSize(m.Width, m.Height)
		m.OrganelleHelp.SetSize(m.Width, m.Height)
		m.TargetHelp.SetSize(m.Width, m.Height)
	case renderCellMarkdownMsg:
		m.CellHelp, cmd = m.CellHelp.Update(msg.msg)
		return m, cmd
	case renderOrganelleMarkdownMsg:
		m.OrganelleHelp, cmd = m.OrganelleHelp.Update(msg.msg)
		return m, cmd
	case renderTargetMarkdownMsg:
		m.TargetHelp, cmd = m.TargetHelp.Update(msg.msg)
		return m, cmd
	}
	if m.TargetHelp.Active {
		m.TargetHelp, cmd = m.TargetHelp.Update(msg)
	} else if m.CellHelp.Active {
		m.CellHelp, cmd = m.CellHelp.Update(msg)
	} else if m.OrganelleHelp.Active {
		m.OrganelleHelp, cmd = m.OrganelleHelp.Update(msg)
	}
	return m, cmd
}

func (m *ReadmeModel) View() string {
	// Tabs
	var (
		tabs    []string
		content string
	)
	if m.CellHelp.Active {
		tabs = append(tabs, activeTab.Render(fmt.Sprintf("Cell: %s", m.Target.StdCell)))
		content = m.CellHelp.View()
	} else {
		tabs = append(tabs, tab.Render(fmt.Sprintf("Cell: %s", m.Target.StdCell)))
	}
	if m.OrganelleHelp.Active {
		tabs = append(tabs, activeTab.Render(fmt.Sprintf("Organelle: %s", m.Target.StdOrganelle)))
		content = m.OrganelleHelp.View()
	} else {
		tabs = append(tabs, tab.Render(fmt.Sprintf("Organelle: %s", m.Target.StdOrganelle)))
	}
	if m.TargetHelp.Active {
		tabs = append(tabs, activeTab.Render(fmt.Sprintf("Target: %s", m.Target.StdName)))
		content = m.TargetHelp.View()
	} else {
		tabs = append(tabs, tab.Render(fmt.Sprintf("Target: %s", m.Target.StdName)))
	}

	row := lipgloss.JoinHorizontal(lipgloss.Top, tabs...)
	gap := tabGap.Render(strings.Repeat(" ", max(0, m.Width-lipgloss.Width(row)-2)))
	row = lipgloss.JoinHorizontal(lipgloss.Bottom, row, gap)

	return lipgloss.JoinVertical(lipgloss.Top, row, content)
}

func (m *ReadmeModel) ShortHelp() []key.Binding {
	kb := []key.Binding{
		m.KeyMap.Up,
		m.KeyMap.Down,
		m.KeyMap.HalfPageUp,
		m.KeyMap.HalfPageDown,
		m.KeyMap.CycleTab,
		m.KeyMap.CloseReadme,
	}
	return kb
}

func (m *ReadmeModel) FullHelp() [][]key.Binding {
	kb := [][]key.Binding{{}}
	return kb
}
func max(a, b int) int {
	if a > b {
		return a
	}
	return b
}
