package data

import (
	"fmt"

	"github.com/hymkor/go-lazy"

	"github.com/divnix/std/flake"
)

var (
	targetTemplate = "//%s/%s/%s"
	actionTemplate = "//%s/%s/%s:%s"
	noReadme       = "🥺 No Readme available ...\n\n💡 But hey! You could create one ...\n\n💪 Start with: `$EDITOR %s`\n\n👉 It will also be rendered in the docs!"
	noDescription  = "🥺 Target has no 'meta.description' attribute"
	cellsFrom      = lazy.Of[string]{
		New: func() string {
			if s, err := flake.GetCellsFrom(); err != nil {
				return "${cellsFrom}"
			} else {
				return s
			}
		},
	}
)

type Root struct {
	Cells []Cell
}

type Cell struct {
	Name   string  `json:"cell"`
	Readme *string `json:"readme,omitempty"`
	Blocks []Block `json:"cellBlocks"`
}

type Block struct {
	Name      string   `json:"cellBlock"`
	Readme    *string  `json:"readme,omitempty"`
	Blocktype string   `json:"blockType"`
	Targets   []Target `json:"targets"`
}

type Action struct {
	Name  string `json:"name"`
	Descr string `json:"description"`
}

func (a Action) Title() string       { return a.Name }
func (a Action) Description() string { return a.Descr }
func (a Action) FilterValue() string { return a.Title() }

type Target struct {
	Name    string   `json:"name"`
	Readme  *string  `json:"readme,omitempty"`
	Deps    []string `json:"deps"`
	Descr   *string  `json:"description,omitempty"`
	Actions []Action `json:"actions"`
}

func (t Target) Description() string {
	if t.Descr != nil {
		return "💡 " + *t.Descr
	} else {
		return noDescription
	}
}

func (r *Root) Select(ci, oi, ti int) (Cell, Block, Target) {
	var (
		c = r.Cells[ci]
		o = c.Blocks[oi]
		t = o.Targets[ti]
	)
	return c, o, t
}

func (r *Root) ActionArg(ci, oi, ti, ai int) string {
	c, o, t := r.Select(ci, oi, ti)
	a := t.Actions[ai]
	return fmt.Sprintf(actionTemplate, c.Name, o.Name, t.Name, a.Name)
}

func (r *Root) ActionTitle(ci, oi, ti, ai int) string {
	_, _, t := r.Select(ci, oi, ti)
	a := t.Actions[ai]
	return a.Title()
}

func (r *Root) ActionDescription(ci, oi, ti, ai int) string {
	_, _, t := r.Select(ci, oi, ti)
	a := t.Actions[ai]
	return a.Description()
}

func (r *Root) TargetTitle(ci, oi, ti int) string {
	c, o, t := r.Select(ci, oi, ti)
	return fmt.Sprintf(targetTemplate, c.Name, o.Name, t.Name)
}

func (r *Root) TargetDescription(ci, oi, ti int) string {
	_, _, t := r.Select(ci, oi, ti)
	return t.Description()
}
func (r *Root) Cell(ci, oi, ti int) Cell       { c, _, _ := r.Select(ci, oi, ti); return c }
func (r *Root) CellName(ci, oi, ti int) string { return r.Cell(ci, oi, ti).Name }
func (r *Root) CellHelp(ci, oi, ti int) string {
	if r.HasCellHelp(ci, oi, ti) {
		return *r.Cell(ci, oi, ti).Readme
	} else {
		return fmt.Sprintf(noReadme, fmt.Sprintf("%s/%s/Readme.md", cellsFrom.Value(), r.CellName(ci, oi, ti)))
	}
}
func (r *Root) HasCellHelp(ci, oi, ti int) bool {
	c := r.Cell(ci, oi, ti)
	return c.Readme != nil
}
func (r *Root) Block(ci, oi, ti int) Block      { _, o, _ := r.Select(ci, oi, ti); return o }
func (r *Root) BlockName(ci, oi, ti int) string { return r.Block(ci, oi, ti).Name }
func (r *Root) BlockHelp(ci, oi, ti int) string {
	if r.HasBlockHelp(ci, oi, ti) {
		return *r.Block(ci, oi, ti).Readme
	} else {
		return fmt.Sprintf(noReadme, fmt.Sprintf("%s/%s/%s/Readme.md", cellsFrom.Value(), r.CellName(ci, oi, ti), r.BlockName(ci, oi, ti)))
	}
}
func (r *Root) HasBlockHelp(ci, oi, ti int) bool {
	b := r.Block(ci, oi, ti)
	return b.Readme != nil
}
func (r *Root) Target(ci, oi, ti int) Target     { _, _, t := r.Select(ci, oi, ti); return t }
func (r *Root) TargetName(ci, oi, ti int) string { return r.Target(ci, oi, ti).Name }
func (r *Root) TargetHelp(ci, oi, ti int) string {
	if r.HasTargetHelp(ci, oi, ti) {
		return *r.Target(ci, oi, ti).Readme
	} else {
		return fmt.Sprintf(noReadme, fmt.Sprintf("%s/%s/%s/%s.md", cellsFrom.Value(), r.CellName(ci, oi, ti), r.BlockName(ci, oi, ti), r.TargetName(ci, oi, ti)))
	}
}
func (r *Root) HasTargetHelp(ci, oi, ti int) bool {
	t := r.Target(ci, oi, ti)
	return t.Readme != nil
}

func (r *Root) Len() int {
	sum := 0
	for _, c := range r.Cells {
		for _, o := range c.Blocks {
			sum += len(o.Targets)
		}
	}
	return sum
}
