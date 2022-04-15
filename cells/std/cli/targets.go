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
	switch msg := msg.(type) {
	case tea.KeyMsg:
		switch msg.String() {
		}
		m.List, cmd = m.List.Update(msg)
		return m, cmd
	case tea.WindowSizeMsg:
	}
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
	targetList.StartSpinner()

	return &TargetModel{targetList}
}

type item struct {
	name        string `json:"__std_name"`
	organelle   string `json:"__std_organelle"`
	cell        string `json:"__std_cell"`
	clade       string `json:"__std_clade"`
	description string `json:"__std_description"`
	actions     []action
}

func (i item) Title() string       { return fmt.Sprintf(targetTemplate, i.cell, i.organelle, i.name) }
func (i item) Description() string { return i.description }
func (i item) FilterValue() string { return i.Title() }
