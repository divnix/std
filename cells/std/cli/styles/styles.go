package styles

import (
	"github.com/charmbracelet/lipgloss"
)

var (
	Highlight = lipgloss.AdaptiveColor{Light: "#874BFD", Dark: "#7D56F4"}
	AppStyle  = lipgloss.NewStyle().Padding(1, 2)

	ErrorStyle = lipgloss.NewStyle().
			BorderStyle(lipgloss.NormalBorder()).
			BorderForeground(Highlight).Padding(0, 1)

	TargetStyle = lipgloss.NewStyle().
			BorderStyle(lipgloss.NormalBorder()).
			BorderForeground(Highlight)

	ActionInspectionStyle = lipgloss.NewStyle().
				BorderStyle(lipgloss.NormalBorder()).
				BorderForeground(Highlight).Padding(0, 1).Faint(true)

	ActionStyle = lipgloss.NewStyle().
			BorderStyle(lipgloss.NormalBorder()).
			BorderForeground(Highlight)

	ReadmeStyle = lipgloss.NewStyle().
		// BorderStyle(lipgloss.NormalBorder()).
		BorderForeground(Highlight)

	LegendStyle = lipgloss.NewStyle().Padding(1, 0, 0, 2)

	TitleStyle = lipgloss.NewStyle().
			Foreground(Highlight).Bold(true).
			Padding(1, 1)
)
