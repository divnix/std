package main

import (
	"fmt"

	"github.com/charmbracelet/bubbles/key"
	"github.com/charmbracelet/bubbles/list"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

var (
	ActionStyle = lipgloss.NewStyle().
		Width(30).Height(32).
		BorderStyle(lipgloss.NormalBorder()).
		BorderForeground(lipgloss.Color("63"))
)

type ActionModel struct {
	List list.Model
}

func (m *ActionModel) Init() tea.Cmd { return nil }

func (m *ActionModel) Update(msg tea.Msg) (*ActionModel, tea.Cmd) {
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
func (m *ActionModel) View() string {
	return ActionStyle.Render(m.List.View())
}

func NewAction(i item) *ActionModel {
	var (
		appKeys  = NewAppKeyMap()
		numItems = cap(i.actions)
	)
	// Make list of actions
	items := make([]list.Item, numItems)
	for j := 0; j < numItems; j++ {
		items[j] = i.actions[j]
	}
	actionList := list.New(items, list.NewDefaultDelegate(), 0, 32)
	actionList.Title = fmt.Sprintf("Actions for %s", i.StdClade)
	actionList.KeyMap = DefaultListKeyMap()
	actionList.AdditionalShortHelpKeys = func() []key.Binding {
		return []key.Binding{
			appKeys.toggleFocus,
		}
	}
	actionList.AdditionalFullHelpKeys = func() []key.Binding {
		return []key.Binding{
			appKeys.toggleFocus,
		}
	}
	actionList.SetShowPagination(false)
	actionList.SetShowHelp(false)
	actionList.SetShowStatusBar(false)
	actionList.SetFilteringEnabled(false)

	return &ActionModel{actionList}
}

type action struct {
	ActionName        string   `json:"__action_name"`
	ActionCommand     []string `json:"__action_command"`
	ActionDescription string   `json:"__action_description"`
}

func (a action) Title() string       { return a.ActionName }
func (a action) Description() string { return a.ActionDescription }
func (a action) FilterValue() string { return a.Title() }
