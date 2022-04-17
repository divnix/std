package main

import (
	"fmt"

	"github.com/charmbracelet/bubbles/key"
	"github.com/charmbracelet/bubbles/list"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

const targetTemplate = "//%s/%s:%s"

type TargetModel struct {
	List   list.Model
	Width  int
	Height int
}

func (m *TargetModel) Init() tea.Cmd { return nil }
func (m *TargetModel) Update(msg tea.Msg) (*TargetModel, tea.Cmd) {
	var (
		appKeys = NewAppKeyMap()
		cmd     tea.Cmd
	)
	switch msg := msg.(type) {
	case tea.KeyMsg:
		switch {
		case key.Matches(msg, appKeys.ToggleFocus):
			cmd = m.List.ToggleSpinner()
			return m, cmd
		}
	case tea.WindowSizeMsg:
		m.List.SetHeight(m.Height)
		m.List.SetWidth(m.Width)
		return m, nil
	}
	m.List, cmd = m.List.Update(msg)
	return m, cmd
}
func (m *TargetModel) View() string {
	return lipgloss.NewStyle().Width(m.Width).Height(m.Height).Render(m.List.View())
}

func InitialTarget() *TargetModel {
	var (
		targetsGenerator randomItemGenerator
	)

	// Make initial list of items
	const numItems = 24
	items := make([]list.Item, numItems)
	for i := 0; i < numItems; i++ {
		items[i] = targetsGenerator.next()
	}

	targetList := list.New(items, list.NewDefaultDelegate(), 0, 0)
	targetList.Title = "Target"
	targetList.KeyMap = DefaultListKeyMap()
	targetList.SetFilteringEnabled(true)
	targetList.StartSpinner()
	targetList.DisableQuitKeybindings()
	targetList.SetShowHelp(false)

	return &TargetModel{List: targetList}
}

func (m *TargetModel) SelectedItem() *item {
	if m.List.SelectedItem() == nil {
		return nil
	}
	var i = m.List.SelectedItem().(item)
	return &i
}

func (m *TargetModel) HelpView() string {
	return m.List.Help.View(m)
}

func (m *TargetModel) ShortHelp() []key.Binding {
	// switch off the list's help
	m.List.KeyMap.ShowFullHelp.SetEnabled(false)
	m.List.KeyMap.CloseFullHelp.SetEnabled(false)
	return m.List.ShortHelp()
}

func (m *TargetModel) FullHelp() [][]key.Binding {
	kb := [][]key.Binding{{}}
	return kb
}

type item struct {
	StdName        string `json:"__std_name"`
	StdOrganelle   string `json:"__std_organelle"`
	StdCell        string `json:"__std_cell"`
	StdClade       string `json:"__std_clade"`
	StdDescription string `json:"__std_description"`
	StdReadme      string `json:"__std_readme"`
	actions        []action
}

func (i item) Title() string {
	return fmt.Sprintf(targetTemplate, i.StdCell, i.StdOrganelle, i.StdName)
}
func (i item) Description() string { return i.StdDescription }
func (i item) FilterValue() string { return i.Title() }

func (i item) GetActionItems() []list.Item {
	var numItems = cap(i.actions)
	// Make list of actions
	items := make([]list.Item, numItems)
	for j := 0; j < numItems; j++ {
		items[j] = i.actions[j]
	}
	return items
}
