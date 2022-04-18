package models

import (
	"fmt"

	"github.com/charmbracelet/bubbles/key"
	"github.com/charmbracelet/bubbles/list"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"

	"github.com/divnix/std/cells/std/cli/data"
	"github.com/divnix/std/cells/std/cli/keys"
)

type ActionModel struct {
	Target *data.Item
	List   list.Model
	Width  int
	Height int
}

func (m *ActionModel) SetTarget(t *data.Item) {
	m.Target = t
	m.List.Title = fmt.Sprintf("Actions for %s", t.StdClade)
	m.List.SetItems(t.GetActionItems())
}

func (m *ActionModel) Init() tea.Cmd { return nil }

func (m *ActionModel) Update(msg tea.Msg) (*ActionModel, tea.Cmd) {
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
func (m *ActionModel) View() string {
	return lipgloss.NewStyle().Width(m.Width).Height(m.Height).Render(m.List.View())
}

func (m *ActionModel) HelpView() string {
	return m.List.Help.View(m)
}

func (m *ActionModel) ShortHelp() []key.Binding {
	// switch off the list's help
	m.List.KeyMap.ShowFullHelp.SetEnabled(false)
	m.List.KeyMap.CloseFullHelp.SetEnabled(false)
	return m.List.ShortHelp()
}

func (m *ActionModel) FullHelp() [][]key.Binding {
	kb := [][]key.Binding{{}}
	return kb
}

func NewAction() *ActionModel {

	actionList := list.New([]list.Item{}, list.NewDefaultDelegate(), 0, 0)
	actionList.Title = fmt.Sprintf("Actions")
	actionList.KeyMap = keys.DefaultListKeyMap()
	actionList.SetShowPagination(false)
	actionList.SetShowHelp(false)
	actionList.SetShowStatusBar(false)
	actionList.SetFilteringEnabled(false)
	actionList.DisableQuitKeybindings()

	return &ActionModel{List: actionList}
}

func (m *ActionModel) SelectedItem() *data.Action {
	if m.List.SelectedItem() == nil {
		return nil
	}
	var i = m.List.SelectedItem().(data.Action)
	return &i
}
