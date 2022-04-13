package main

import (
	"math/rand"
	"sync"
)

type randomItemGenerator struct {
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
	mtx            *sync.Mutex
	shuffle        *sync.Once
}

func (r *randomItemGenerator) reset() {
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

	r.shuffle.Do(func() {
		shuf := func(x []string) {
			rand.Shuffle(len(x), func(i, j int) { x[i], x[j] = x[j], x[i] })
		}
		shuf(r.names)
		shuf(r.cells)
		shuf(r.organelles)
		shuf(r.clades)
		shuf(r.descs)
	})
}

func (r *randomItemGenerator) next() item {
	if r.mtx == nil {
		r.reset()
	}

	r.mtx.Lock()
	defer r.mtx.Unlock()

	i := item{
		name:        r.names[r.nameIndex],
		organelle:   r.organelles[r.organelleIndex],
		cell:        r.cells[r.cellIndex],
		clade:       r.clades[r.cladeIndex],
		description: r.descs[r.descIndex],
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

	return i
}
