package data

import (
	"fmt"
)

var (
	targetTemplate = "//%s/%s/%s"
	actionTemplate = "//%s/%s/%s:%s"
)

type Root struct {
	Cells []Cell
}

type Cell struct {
	Cell   string  `json:"cell"`
	Readme string  `json:"readme"`
	Blocks []Block `json:"cellBlocks"`
}

type Block struct {
	Block     string   `json:"cellBlock"`
	Readme    string   `json:"readme"`
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
	Target      string   `json:"name"`
	Readme      string   `json:"readme"`
	Deps        []string `json:"deps"`
	Description string   `json:"description"`
	Actions     []Action `json:"actions"`
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
	return fmt.Sprintf(actionTemplate, c.Cell, o.Block, t.Target, a.Name)
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
	return fmt.Sprintf(targetTemplate, c.Cell, o.Block, t.Target)
}

func (r *Root) TargetDescription(ci, oi, ti int) string {
	_, _, t := r.Select(ci, oi, ti)
	return t.Description
}
func (r *Root) Cell(ci, oi, ti int) string        { c, _, _ := r.Select(ci, oi, ti); return c.Cell }
func (r *Root) CellHelp(ci, oi, ti int) string    { c, _, _ := r.Select(ci, oi, ti); return c.Readme }
func (r *Root) HasCellHelp(ci, oi, ti int) bool   { return r.CellHelp(ci, oi, ti) != "" }
func (r *Root) Block(ci, oi, ti int) string       { _, o, _ := r.Select(ci, oi, ti); return o.Block }
func (r *Root) BlockHelp(ci, oi, ti int) string   { _, o, _ := r.Select(ci, oi, ti); return o.Readme }
func (r *Root) HasBlockHelp(ci, oi, ti int) bool  { return r.BlockHelp(ci, oi, ti) != "" }
func (r *Root) Target(ci, oi, ti int) string      { _, _, t := r.Select(ci, oi, ti); return t.Target }
func (r *Root) TargetHelp(ci, oi, ti int) string  { _, _, t := r.Select(ci, oi, ti); return t.Readme }
func (r *Root) HasTargetHelp(ci, oi, ti int) bool { return r.TargetHelp(ci, oi, ti) != "" }

func (r *Root) Len() int {
	sum := 0
	for _, c := range r.Cells {
		for _, o := range c.Blocks {
			sum += len(o.Targets)
		}
	}
	return sum
}
