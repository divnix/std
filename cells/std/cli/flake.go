package main

import (
	// "fmt"

	tea "github.com/charmbracelet/bubbletea"
)

func loadFlake() tea.Msg {
	var (
		targetsGenerator randomItemGenerator
	)

	// // Make list of actions
	// items := make([]list.Item, numItems)
	// for j := 0; j < numItems; j++ {
	// 	items[j] = i.actions[j]
	// }
	// Make initial list of items
	const numItems = 24
	items := make([]item, numItems)
	for i := 0; i < numItems; i++ {
		items[i] = targetsGenerator.next()
	}
	return flakeLoadedMsg{
		Items: items,
	}
}

type flakeLoadedMsg struct {
	Items []item
}

type errMsg struct{ err error }

func (e errMsg) Error() string { return e.err.Error() }
