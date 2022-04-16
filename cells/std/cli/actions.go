package main

import (
	"fmt"

	"github.com/charmbracelet/bubbles/key"
	"github.com/charmbracelet/bubbles/list"
	tea "github.com/charmbracelet/bubbletea"
)

type ActionModel struct {
	List   list.Model
	Width  int
	Height int
}

func (m *ActionModel) Init() tea.Cmd { return nil }

func (m *ActionModel) Update(msg tea.Msg) (*ActionModel, tea.Cmd) {
	var cmd tea.Cmd
	m.List, cmd = m.List.Update(msg)
	return m, cmd
}
func (m *ActionModel) View() string {
	return m.List.View()
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

	return &ActionModel{
		List: actionList,
	}
}

type action struct {
	ActionName        string   `json:"__action_name"`
	ActionCommand     []string `json:"__action_command"`
	ActionDescription string   `json:"__action_description"`
}

func (a action) Title() string       { return a.ActionName }
func (a action) Description() string { return a.ActionDescription }
func (a action) FilterValue() string { return a.Title() }
