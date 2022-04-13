package main

import (
	// "encoding/json"
	"fmt"
	"math/rand"
	"os"
	"time"

	"github.com/charmbracelet/bubbles/key"
	"github.com/charmbracelet/bubbles/list"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
	boxer "github.com/treilik/bubbleboxer"
)

var (
	appStyle = lipgloss.NewStyle().Padding(1, 2)

	titleStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color("#FFFDF5")).
			Background(lipgloss.Color("#25A065")).
			Padding(0, 1)

	statusMessageStyle = lipgloss.NewStyle().
				Foreground(lipgloss.AdaptiveColor{Light: "#04B575", Dark: "#04B575"}).
				Render

	targetRender = "//%s/%s:%s"
)

type item struct {
	name        string `json:"__std_name"`
	organelle   string `json:"__std_organelle"`
	cell        string `json:"__std_cell"`
	clade       string `json:"__std_clade"`
	description string `json:"__std_description"`
}

func (i item) Title() string       { return fmt.Sprintf(targetRender, i.cell, i.organelle, i.name) }
func (i item) Description() string { return i.description }
func (i item) FilterValue() string { return i.Title() }

type listKeyMap struct {
	toggleSpinner    key.Binding
	toggleTitleBar   key.Binding
	toggleStatusBar  key.Binding
	togglePagination key.Binding
}

func newListKeyMap() *listKeyMap {
	return &listKeyMap{
		toggleSpinner: key.NewBinding(
			key.WithKeys("s"),
			key.WithHelp("s", "toggle spinner"),
		),
		toggleTitleBar: key.NewBinding(
			key.WithKeys("T"),
			key.WithHelp("T", "toggle title"),
		),
		toggleStatusBar: key.NewBinding(
			key.WithKeys("S"),
			key.WithHelp("S", "toggle status"),
		),
		togglePagination: key.NewBinding(
			key.WithKeys("P"),
			key.WithHelp("P", "toggle pagination"),
		),
	}
}

type model struct {
	tui           boxer.Boxer
	list          list.Model
	itemGenerator *randomItemGenerator
	keys          *listKeyMap
	delegateKeys  *delegateKeyMap
}

func newModel() model {
	var (
		itemGenerator randomItemGenerator
		delegateKeys  = newDelegateKeyMap()
		listKeys      = newListKeyMap()
	)

	// Make initial list of items
	const numItems = 24
	items := make([]list.Item, numItems)
	for i := 0; i < numItems; i++ {
		items[i] = itemGenerator.next()
	}

	// Setup list
	delegate := newItemDelegate(delegateKeys)
	targetList := list.New(items, delegate, 0, 0)
	targetList.Title = "Standard Targets"
	targetList.Styles.Title = titleStyle
	targetList.AdditionalFullHelpKeys = func() []key.Binding {
		return []key.Binding{
			listKeys.toggleSpinner,
			listKeys.toggleTitleBar,
			listKeys.toggleStatusBar,
			listKeys.togglePagination,
		}
	}
	// TODO: read std metadata via nix eval
	// stdMetaJson := `[{"__std_name": "name","__std_organelle": "organelle","__std_cell": "cell","__std_clade": "clade","__std_description": "A description ..."}]`
	//	stdMeta:            json.Unmarshal([]byte(stdMetaJson), &stdMeta),
	//	system:             "x86_64-linux",
	// stdMeta represents the std metadata
	// type stdMeta []struct {
	// }
	return model{
		list:          targetList,
		keys:          listKeys,
		delegateKeys:  delegateKeys,
		itemGenerator: &itemGenerator,
	}
}

func (m model) Init() tea.Cmd {
	return tea.EnterAltScreen
}

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	var cmds []tea.Cmd

	switch msg := msg.(type) {
	case tea.WindowSizeMsg:
		h, v := appStyle.GetFrameSize()
		m.list.SetSize(msg.Width-h, msg.Height-v)

	case tea.KeyMsg:
		// Don't match any of the keys below if we're actively filtering.
		if m.list.FilterState() == list.Filtering {
			break
		}

		switch {
		case key.Matches(msg, m.keys.toggleSpinner):
			cmd := m.list.ToggleSpinner()
			return m, cmd

		case key.Matches(msg, m.keys.toggleTitleBar):
			v := !m.list.ShowTitle()
			m.list.SetShowTitle(v)
			m.list.SetShowFilter(v)
			m.list.SetFilteringEnabled(v)
			return m, nil

		case key.Matches(msg, m.keys.toggleStatusBar):
			m.list.SetShowStatusBar(!m.list.ShowStatusBar())
			return m, nil

		case key.Matches(msg, m.keys.togglePagination):
			m.list.SetShowPagination(!m.list.ShowPagination())
			return m, nil

			//case key.Matches(msg, m.keys.insertItem):
			//	m.delegateKeys.remove.SetEnabled(true)
			//	newItem := m.itemGenerator.next()
			//	insCmd := m.list.InsertItem(0, newItem)
			//	statusCmd := m.list.NewStatusMessage(statusMessageStyle("Added " + newItem.Title()))
			//	return m, tea.Batch(insCmd, statusCmd)
		}
	}

	// This will also call our delegate's update function.
	newListModel, cmd := m.list.Update(msg)
	m.list = newListModel
	cmds = append(cmds, cmd)

	return m, tea.Batch(cmds...)
}

func (m model) View() string {
	return appStyle.Render(m.list.View())
}

func main() {
	rand.Seed(time.Now().UTC().UnixNano())

	if err := tea.NewProgram(newModel()).Start(); err != nil {
		fmt.Println("Error running program:", err)
		os.Exit(1)
	}
}
