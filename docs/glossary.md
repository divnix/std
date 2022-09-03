# Glossary

**Cell**

: A Cell is the folder name of the first level under `${cellsFrom}`. They represent a coherent semantic collection of functionality.

**Cell Block**

: An Cell Block is the specific _named type_ of a Standard (and hence: Flake) output.

**Clade**

: A Clade is the unnamed generic type of an Cell Block and may or may not implement Clade Actions.

**Target**

: A Target is the actual output of an Cell Block. If there is only one intended output, it is called `default` by convention.

**Action**

: An Action is a runnable procedure implemented on the generic Clade type. These are abstract procedures that are valuable in any concrete Cell Block of such Clade.
