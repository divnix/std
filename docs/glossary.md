# Glossary

**Cell**

: A Cell is the folder name of the first level under `${cellsFrom}`. They represent a coherent semantic collection of functionality.

**Cell Block**

: A Cell Block is the specific _named type_ of a Standard (and hence: Flake) output.

**Block Type**

: A Block Type is the unnamed generic type of a Cell Block and may or may not implement Block Type Actions.

**Target**

: A Target is the actual output of a Cell Block. If there is only one intended output, it is called `default` by convention.

**Action**

: An Action is a runnable procedure implemented on the generic Block Type type. These are abstract procedures that are valuable in any concrete Cell Block of such Block Type.

**The Registry**

: The Registry, in the context of Standard and if it doesn't refer to a well-known external concept, means the `.#__std` flake output. This Registry holds different Registers that serve different discovery purposes. For example, the CLI can discover relevant metadata or a CI can discover desired pipeline targets.
