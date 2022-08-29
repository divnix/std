# Glossary

**Cell**

: A Cell is the folder name of the first level under `${cellsFrom}`. They represent a coherent semantic collection of functionality.

**Organelle**

: An Organelle is the specific _named type_ of a Standard (and hence: Flake) output.

**Clade**

: A Clade is the unnamed generic type of an Organelle and may or may not implement Clade Actions.

**Target**

: A Target is the actual output of an Organelle. If there is only one intended output, it is called `default` by convention.

**Action**

: An Action is a runnable procedure implemented on the generic Clade type. These are abstract procedures that are valuable in any concrete Organelle of such Clade.
