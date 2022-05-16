package models

import (
	"fmt"
	"strings"

	"github.com/charmbracelet/bubbles/help"
	"github.com/charmbracelet/bubbles/key"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
	"github.com/knipferrc/teacup/markdown"

	"github.com/divnix/std/data"
	"github.com/divnix/std/keys"
	"github.com/divnix/std/styles"
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
	TargetHelp    markdown.Bubble
	CellHelp      markdown.Bubble
	OrganelleHelp markdown.Bubble
	Cell          string
	Organelle     string
	Target        string
	Width         int
	Height        int
	KeyMap        *keys.ReadmeKeyMap
	Help          help.Model
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

func (m *ReadmeModel) LoadReadme(d *data.Root, ci, oi, ti int) {
	m.Cell = d.Cell(ci, oi, ti)
	m.Organelle = d.Organelle(ci, oi, ti)
	m.Target = d.Target(ci, oi, ti)
	if d.HasTargetHelp(ci, oi, ti) {
		m.TargetHelp.Viewport.SetContent(fmt.Sprintf("Rendering %s ...", d.TargetHelp(ci, oi, ti)))
	} else {
		content := lipgloss.NewStyle().
			Width(m.Width).
			Height(m.Height).
			Render(fmt.Sprintf(
				noTargetReadme,
				d.TargetTitle(ci, oi, ti),
				d.Cell(ci, oi, ti),
				d.Organelle(ci, oi, ti),
				d.Target(ci, oi, ti),
			))
		m.TargetHelp.Viewport.SetContent(content)
	}
	if d.HasCellHelp(ci, oi, ti) {
		m.CellHelp.Viewport.SetContent(fmt.Sprintf("Rendering %s ...", d.CellHelp(ci, oi, ti)))
	} else {
		content := lipgloss.NewStyle().
			Width(m.Width).
			Height(m.Height).
			Render(fmt.Sprintf(
				noCellReadme,
				d.Cell(ci, oi, ti),
				d.Cell(ci, oi, ti),
			))
		m.CellHelp.Viewport.SetContent(content)
	}
	if d.HasOrganelleHelp(ci, oi, ti) {
		m.OrganelleHelp.Viewport.SetContent(fmt.Sprintf("Rendering %s ...", d.OrganelleHelp(ci, oi, ti)))
	} else {
		content := lipgloss.NewStyle().
			Width(m.Width).
			Height(m.Height).
			Render(fmt.Sprintf(
				noOrganelleReadme,
				d.Cell(ci, oi, ti),
				d.Organelle(ci, oi, ti),
				d.Cell(ci, oi, ti),
				d.Organelle(ci, oi, ti),
			))
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

func (m *ReadmeModel) RenderMarkdown(d *data.Root, ci, oi, ti int) tea.Cmd {
	var (
		cmds []tea.Cmd
		cmd  tea.Cmd
	)
	m.LoadReadme(d, ci, oi, ti)
	m.TargetHelp.SetIsActive(true)
	if d.HasCellHelp(ci, oi, ti) {
		cmd = func() tea.Msg {
			return renderCellMarkdownMsg{
				m.CellHelp.SetFileName(
					d.CellHelp(ci, oi, ti),
				)(),
			}
		}
		cmds = append(cmds, cmd)
	}
	if d.HasOrganelleHelp(ci, oi, ti) {
		cmd = func() tea.Msg {
			return renderOrganelleMarkdownMsg{
				m.OrganelleHelp.SetFileName(
					d.OrganelleHelp(ci, oi, ti),
				)(),
			}
		}
		cmds = append(cmds, cmd)
	}
	if d.HasTargetHelp(ci, oi, ti) {
		cmd = func() tea.Msg {
			return renderTargetMarkdownMsg{
				m.TargetHelp.SetFileName(
					d.TargetHelp(ci, oi, ti),
				)(),
			}
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
		tabs = append(tabs, activeTab.Render(fmt.Sprintf("Cell: %s", m.Cell)))
		content = m.CellHelp.View()
	} else {
		tabs = append(tabs, tab.Render(fmt.Sprintf("Cell: %s", m.Cell)))
	}
	if m.OrganelleHelp.Active {
		tabs = append(tabs, activeTab.Render(fmt.Sprintf("Organelle: %s", m.Organelle)))
		content = m.OrganelleHelp.View()
	} else {
		tabs = append(tabs, tab.Render(fmt.Sprintf("Organelle: %s", m.Organelle)))
	}
	if m.TargetHelp.Active {
		tabs = append(tabs, activeTab.Render(fmt.Sprintf("Target: %s", m.Target)))
		content = m.TargetHelp.View()
	} else {
		tabs = append(tabs, tab.Render(fmt.Sprintf("Target: %s", m.Target)))
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
