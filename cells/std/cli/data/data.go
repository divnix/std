package data

import (
	"fmt"

	"github.com/charmbracelet/bubbles/list"
)

const targetTemplate = "//%s/%s:%s"

type Item struct {
	StdName         string `json:"__std_name"`
	StdOrganelle    string `json:"__std_organelle"`
	StdCell         string `json:"__std_cell"`
	StdClade        string `json:"__std_clade"`
	StdDescription  string `json:"__std_description"`
	StdReadme       string `json:"__std_readme"`
	StdCladeActions []Action
}

func (i Item) Title() string {
	return fmt.Sprintf(targetTemplate, i.StdCell, i.StdOrganelle, i.StdName)
}
func (i Item) Description() string { return i.StdDescription }
func (i Item) FilterValue() string { return i.Title() }

func (i Item) GetActionItems() []list.Item {
	var numItems = cap(i.StdCladeActions)
	// Make list of actions
	items := make([]list.Item, numItems)
	for j := 0; j < numItems; j++ {
		items[j] = i.StdCladeActions[j]
	}
	return items
}

type Action struct {
	ActionName        string   `json:"__action_name"`
	ActionCommand     []string `json:"__action_command"`
	ActionDescription string   `json:"__action_description"`
}

func (a Action) Title() string       { return a.ActionName }
func (a Action) Description() string { return a.ActionDescription }
func (a Action) FilterValue() string { return a.Title() }
