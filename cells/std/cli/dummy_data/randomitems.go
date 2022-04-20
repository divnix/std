package dummy_data

import (
	"math/rand"
	"sync"

	"github.com/divnix/std/data"
)

type RandomItemGenerator struct {
	names          []string
	nameIndex      int
	organelles     []string
	organelleIndex int
	cells          []string
	cellIndex      int
	clades         []string
	cladeIndex     int
	descs          []string
	descIndex      int
	readmes        []string
	readmeIndex    int
	mtx            *sync.Mutex
	shuffle        *sync.Once
}

func (r *RandomItemGenerator) reset() {
	r.mtx = &sync.Mutex{}
	r.shuffle = &sync.Once{}

	// stdMetaJson := `[{"__std_name": "name","__std_organelle": "organelle","__std_cell": "cell","__std_clade": "clade","__std_description": "A description ..."}]`
	r.names = []string{
		"name",
		"default",
		"backend",
	}

	r.cells = []string{
		"cloud",
		"metal",
		"automation",
	}

	r.organelles = []string{
		"oci-images",
		"nomadEnvs",
		"hydrationProfile",
		"bitteProfile",
		"constants",
		"entrypoints",
		"packages",
		"healthChecks",
	}

	r.clades = []string{
		"data",
		"functions",
		"installables",
		"runnables",
	}

	r.descs = []string{
		"A little weird",
		"Bold flavor",
		"Can’t get enough",
		"Delectable",
		"Expensive",
		"Expired",
		"Exquisite",
		"Fresh",
		"Gimme",
		"In season",
		"Kind of spicy",
		"Looks fresh",
		"Looks good to me",
		"Maybe not",
		"My favorite",
		"Oh my",
		"On sale",
		"Organic",
		"Questionable",
		"Really fresh",
		"Refreshing",
		"Salty",
		"Scrumptious",
		"Delectable",
		"Slightly sweet",
		"Smells great",
		"Tasty",
		"Too ripe",
		"At last",
		"What?",
		"Wow",
		"Yum",
		"Maybe",
		"Sure, why not?",
	}

	r.readmes = []string{
		"./dummy_data/random-readme-1.md",
		"./dummy_data/random-readme-2.md",
		"",
	}

	r.shuffle.Do(func() {
		shuf := func(x []string) {
			rand.Shuffle(len(x), func(i, j int) { x[i], x[j] = x[j], x[i] })
		}
		shuf(r.names)
		shuf(r.cells)
		shuf(r.organelles)
		shuf(r.clades)
		shuf(r.descs)
		shuf(r.readmes)
	})
}

func (r *RandomItemGenerator) Next() data.Item {
	if r.mtx == nil {
		r.reset()
	}

	r.mtx.Lock()
	defer r.mtx.Unlock()

	var (
		actionsGenerator randomActionGenerator
	)
	// Make actions
	const numItems = 3
	items := make([]data.Action, numItems)
	for i := 0; i < numItems; i++ {
		items[i] = actionsGenerator.next()
	}

	i := data.Item{
		StdName:         r.names[r.nameIndex],
		StdOrganelle:    r.organelles[r.organelleIndex],
		StdCell:         r.cells[r.cellIndex],
		StdClade:        r.clades[r.cladeIndex],
		StdDescription:  r.descs[r.descIndex],
		StdReadme:       r.readmes[r.readmeIndex],
		StdCladeActions: items,
	}

	r.nameIndex++
	if r.nameIndex >= len(r.names) {
		r.nameIndex = 0
	}

	r.organelleIndex++
	if r.organelleIndex >= len(r.organelles) {
		r.organelleIndex = 0
	}

	r.cellIndex++
	if r.cellIndex >= len(r.cells) {
		r.cellIndex = 0
	}

	r.cladeIndex++
	if r.cladeIndex >= len(r.clades) {
		r.cladeIndex = 0
	}

	r.descIndex++
	if r.descIndex >= len(r.descs) {
		r.descIndex = 0
	}

	r.readmeIndex++
	if r.readmeIndex >= len(r.readmes) {
		r.readmeIndex = 0
	}

	return i
}

type randomActionGenerator struct {
	actionNames        []string
	actionNameIndex    int
	actionCommands     [][]string
	actionCommandIndex int
	actionDescs        []string
	actionDescIndex    int
	mtx                *sync.Mutex
	shuffle            *sync.Once
}

func (r *randomActionGenerator) reset() {
	r.mtx = &sync.Mutex{}
	r.shuffle = &sync.Once{}
	r.actionNames = []string{
		"build",
		"run",
		"deploy",
		"serve",
		"validate",
		"test",
	}
	r.actionCommands = [][]string{
		{"nix", "run", ".#f.r.a.g.m.e.n.t"},
		{"nix", "build", ".#fragment", "&&", "nomad", "result/job"},
		{"cat", "./cow"},
		{"cowsay", "hi"},
		{"fastlane", "run", "..."},
		{"go", "build", "."},
	}
	r.actionDescs = []string{
		"A little weird",
		"Bold flavor",
		"Can’t get enough",
		"Delectable",
		"Expensive",
		"Expired",
		"Exquisite",
		"Fresh",
		"Gimme",
		"In season",
		"Kind of spicy",
		"Looks fresh",
		"Looks good to me",
		"Maybe not",
		"My favorite",
		"Oh my",
		"On sale",
		"Organic",
		"Questionable",
		"Really fresh",
		"Refreshing",
		"Salty",
		"Scrumptious",
		"Delectable",
		"Slightly sweet",
		"Smells great",
		"Tasty",
		"Too ripe",
		"At last",
		"What?",
		"Wow",
		"Yum",
		"Maybe",
		"Sure, why not?",
	}

	r.shuffle.Do(func() {
		shufStrings := func(x []string) {
			rand.Shuffle(len(x), func(i, j int) { x[i], x[j] = x[j], x[i] })
		}
		shufLists := func(x [][]string) {
			rand.Shuffle(len(x), func(i, j int) { x[i], x[j] = x[j], x[i] })
		}
		shufStrings(r.actionNames)
		shufLists(r.actionCommands)
		shufStrings(r.actionDescs)
	})

}

func (r *randomActionGenerator) next() data.Action {
	if r.mtx == nil {
		r.reset()
	}

	r.mtx.Lock()
	defer r.mtx.Unlock()

	a := data.Action{
		ActionName:        r.actionNames[r.actionNameIndex],
		ActionCommand:     r.actionCommands[r.actionCommandIndex],
		ActionDescription: r.actionDescs[r.actionDescIndex],
	}

	r.actionNameIndex++
	if r.actionNameIndex >= len(r.actionNames) {
		r.actionNameIndex = 0
	}

	r.actionCommandIndex++
	if r.actionCommandIndex >= len(r.actionCommands) {
		r.actionCommandIndex = 0
	}

	r.actionDescIndex++
	if r.actionDescIndex >= len(r.actionDescs) {
		r.actionDescIndex = 0
	}

	return a
}
