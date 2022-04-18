package models

import (
	"github.com/charmbracelet/bubbles/key"
	"github.com/charmbracelet/bubbles/list"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"

	"github.com/divnix/std/cells/std/cli/data"
	"github.com/divnix/std/cells/std/cli/keys"
)

type TargetModel struct {
	List   list.Model
	Width  int
	Height int
}

func (m *TargetModel) Init() tea.Cmd { return nil }
func (m *TargetModel) Update(msg tea.Msg) (*TargetModel, tea.Cmd) {
	var (
		appKeys = keys.NewAppKeyMap()
		cmd     tea.Cmd
	)
	switch msg := msg.(type) {
	case tea.KeyMsg:
		switch {
		case key.Matches(msg, appKeys.ToggleFocus), key.Matches(msg, appKeys.FocusLeft), key.Matches(msg, appKeys.FocusRight):
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

	targetList := list.New([]list.Item{}, list.NewDefaultDelegate(), 0, 0)
	targetList.Title = "Target"
	targetList.KeyMap = keys.DefaultListKeyMap()
	targetList.SetFilteringEnabled(true)
	targetList.StartSpinner()
	targetList.DisableQuitKeybindings()
	targetList.SetShowHelp(false)

	return &TargetModel{List: targetList}
}

func (m *TargetModel) SelectedItem() *data.Item {
	if m.List.SelectedItem() == nil {
		return nil
	}
	var i = m.List.SelectedItem().(data.Item)
	return &i
}

func (m *TargetModel) SetItems(l []data.Item) {
	var numItems = cap(l)
	// Make list of actions
	items := make([]list.Item, numItems)
	for j := 0; j < numItems; j++ {
		items[j] = l[j]
	}
	m.List.SetItems(items)
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
