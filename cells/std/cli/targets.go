package main

import (
	"fmt"

	"github.com/charmbracelet/bubbles/key"
	"github.com/charmbracelet/bubbles/list"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

const targetTemplate = "//%s/%s:%s"

var TargetStyle = lipgloss.NewStyle().
	Height(32).Width(60).
	BorderStyle(lipgloss.NormalBorder()).
	BorderForeground(lipgloss.Color("63"))

type TargetModel struct {
	List list.Model
}

func (m *TargetModel) Init() tea.Cmd { return nil }
func (m *TargetModel) Update(msg tea.Msg) (*TargetModel, tea.Cmd) {
	var cmd tea.Cmd
	m.List, cmd = m.List.Update(msg)
	return m, cmd
}
func (m *TargetModel) View() string {
	return TargetStyle.Render(m.List.View())
}

func InitialTarget() *TargetModel {
	var (
		targetsGenerator randomItemGenerator
		appKeys          = NewAppKeyMap()
	)

	// Make initial list of items
	const numItems = 24
	items := make([]list.Item, numItems)
	for i := 0; i < numItems; i++ {
		items[i] = targetsGenerator.next()
	}

	targetList := list.New(items, list.NewDefaultDelegate(), 60, 32)
	targetList.Title = "Target"
	targetList.KeyMap = DefaultListKeyMap()
	targetList.AdditionalShortHelpKeys = func() []key.Binding {
		return []key.Binding{
			appKeys.toggleFocus,
		}
	}
	targetList.AdditionalFullHelpKeys = func() []key.Binding {
		return []key.Binding{
			appKeys.toggleFocus,
		}
	}
	targetList.SetShowHelp(false)
	targetList.SetFilteringEnabled(true)

	return &TargetModel{targetList}
}

type item struct {
	StdName        string `json:"__std_name"`
	StdOrganelle   string `json:"__std_organelle"`
	StdCell        string `json:"__std_cell"`
	StdClade       string `json:"__std_clade"`
	StdDescription string `json:"__std_description"`
	actions        []action
}

func (i item) Title() string {
	return fmt.Sprintf(targetTemplate, i.StdCell, i.StdOrganelle, i.StdName)
}
func (i item) Description() string { return i.StdDescription }
func (i item) FilterValue() string { return i.Title() }
