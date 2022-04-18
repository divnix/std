package main

import (
	"encoding/json"

	tea "github.com/charmbracelet/bubbletea"
)

func fakeData() []item {
	var targetsGenerator randomItemGenerator
	const numItems = 24
	items := make([]item, numItems)
	for i := 0; i < numItems; i++ {
		items[i] = targetsGenerator.next()
	}
	return items
}

func loadFlake() tea.Msg {
	var items []item

	json.Unmarshal([]byte(``), &items)

	return flakeLoadedMsg{
		Items: fakeData(),
		// Items: items,
	}
}

type flakeLoadedMsg struct {
	Items []item
}

type errMsg struct{ err error }

func (e errMsg) Error() string { return e.err.Error() }
