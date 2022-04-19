package models

import (
	"fmt"
	"log"
	"os"
	"os/exec"
	"strings"
	"syscall"

	"github.com/charmbracelet/bubbles/key"
	"github.com/charmbracelet/bubbles/list"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"

	"github.com/divnix/std/cells/std/cli/data"
	"github.com/divnix/std/cells/std/cli/keys"
)

type DetachAndQuit int

type ActionExitErrMsg struct {
	cmd string
	err *exec.ExitError
}

func (e ActionExitErrMsg) Error() string {
	return fmt.Sprintf(
		"%s\nresulted in %s\n\nTraceback:\n\n%s",
		lipgloss.NewStyle().Faint(true).Bold(true).Render(e.cmd),
		e.err.Error(),
		string(e.err.Stderr),
	)
}

func newActionDelegate(keys *keys.ActionDelegateKeyMap) list.DefaultDelegate {
	d := list.NewDefaultDelegate()

	d.UpdateFunc = func(msg tea.Msg, m *list.Model) tea.Cmd {
		var command []string

		if i, ok := m.SelectedItem().(data.Action); ok {
			command = i.ActionCommand
		} else {
			return nil
		}

		run := func() tea.Msg {
			binary, lookErr := exec.LookPath("bash")
			if lookErr != nil {
				panic(lookErr)
			}
			args := []string{"bash", "-c", strings.Join(command, " ")}
			env := os.Environ()
			execErr := syscall.Exec(binary, args, env)
			if execErr != nil {
				panic(execErr)
			}
			cmd := exec.Command("bash", append([]string{"-c"}, command...)...)
			cmd.Stdin = os.Stdin
			cmd.Stdout = os.Stdout
			cmd.Stderr = os.Stderr
			err := cmd.Start()
			if err != nil {
				switch exitErr := err.(type) {
				case *exec.ExitError:
					return ActionExitErrMsg{
						cmd: cmd.String(),
						err: exitErr,
					}
				default:
					log.Fatal(err)
				}
			}
			// detach
			cmd.Process.Release()
			return DetachAndQuit(0)
		}

		switch msg := msg.(type) {
		case tea.KeyMsg:
			switch {
			case key.Matches(msg, keys.Exec):
				return run

				// case key.Matches(msg, keys.Inspect):
				// 	return m.NewStatusMessage(statusMessageStyle("Deleted " + title))
			}
		}

		return nil
	}

	help := []key.Binding{keys.Exec, keys.Inspect}
	d.ShortHelpFunc = func() []key.Binding { return help }
	d.FullHelpFunc = func() [][]key.Binding { return [][]key.Binding{} }

	return d
}

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

	actionDelegateKeys := keys.NewActionDelegateKeyMap()
	delegate := newActionDelegate(actionDelegateKeys)
	actionList := list.New([]list.Item{}, delegate, 0, 0)
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
