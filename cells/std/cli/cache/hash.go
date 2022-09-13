// Copyright 2021 Tamás Gulácsi. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package cache

import (
	"crypto/sha256"
	"hash"
)

const HashSize = sha256.Size

type ID [HashSize]byte
type Hash struct {
	hash.Hash
}

func NewHash() Hash { return Hash{Hash: sha256.New()} }
func (h Hash) SumID() ID {
	var a ID
	h.Hash.Sum(a[:0])
	return a
}
