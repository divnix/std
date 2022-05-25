package main

import (
	"fmt"
	"os"

	"github.com/oriser/regroup"

	"github.com/spf13/cobra"
)

type Spec struct {
	Cell      string `regroup:"cell,required"`
	Organelle string `regroup:"organelle,required"`
	Target    string `regroup:"target,required"`
	Action    string `regroup:"action,required"`
}

var re = regroup.MustCompile(`^//(?P<cell>\w+)/(?P<organelle>\w+)/(?P<target>\w+):(?P<action>\w+)`)

var rootCmd = &cobra.Command{
	Use:     "std //cell/organelle/target:action",
	Version: fmt.Sprintf("%s (%s)", buildVersion, buildCommit),
	Short:   "std is the CLI / TUI companion for Standard",
	Long: `std is the CLI / TUI companion for Standard.

- Invoke without any arguments to start the TUI.
- Invoke with a target spec and action to run a known target's action directly.`,
	Args: func(cmd *cobra.Command, args []string) error {
		for _, arg := range args {
			s := &Spec{}
			if err := re.MatchToTarget(arg, s); err != nil {
				return fmt.Errorf("invalid argument format: %s", arg)
			}
		}
		return nil
	},
	Run: func(cmd *cobra.Command, args []string) {
		s := &Spec{}
		if err := re.MatchToTarget(args[0], s); err != nil {
			fmt.Println(err)
			os.Exit(1)
		}
		nix, args, err := GetActionEvalCmdArgs(s.Cell, s.Organelle, s.Target, s.Action)
		if err != nil {
			fmt.Println(err)
			os.Exit(1)
		}
		fmt.Printf("%+v\n", append([]string{nix}, args...))
		if err = bashExecve(append([]string{nix}, args...)); err != nil {
			fmt.Println(err)
			os.Exit(1)
		}

	},
}

func ExecuteCli() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}
