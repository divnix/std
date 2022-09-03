package main

import (
	"fmt"
	"os"
	"time"

	"github.com/oriser/regroup"

	"github.com/rsteube/carapace"
	"github.com/spf13/cobra"
)

type Spec struct {
	Cell   string `regroup:"cell,required"`
	Block  string `regroup:"cellBlock,required"`
	Target string `regroup:"target,required"`
	Action string `regroup:"action,required"`
}

var re = regroup.MustCompile(`^//(?P<cell>[^/]+)/(?P<block>[^/]+)/(?P<target>[^:]+):(?P<action>.+)`)

var rootCmd = &cobra.Command{
	Use:     "std //cell/block/target:action",
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
		nix, args, err := GetActionEvalCmdArgs(s.Cell, s.Block, s.Target, s.Action)
		if err != nil {
			fmt.Println(err)
			os.Exit(1)
		}
		// fmt.Printf("%+v\n", append([]string{nix}, args...))
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

func init() {
	carapace.Gen(rootCmd).Standalone()
	// completes: '//cell/block/target:action'
	carapace.Gen(rootCmd).PositionalAnyCompletion(
		carapace.ActionCallback(func(c carapace.Context) carapace.Action {
			cmd, buf, err := LoadFlakeCmd()
			if err != nil {
				return carapace.ActionMessage(fmt.Sprintf("%v\n", err))
			}
			err = cmd.Run()
			if err != nil {
				return carapace.ActionMessage(fmt.Sprintf("%v\n", err))
			}
			root, err := LoadJson(buf)
			if err != nil {
				return carapace.ActionMessage(fmt.Sprintf("%v\n", err))
			}
			var values = []string{}
			for ci, c := range root.Cells {
				for oi, o := range c.Blocks {
					for ti, t := range o.Targets {
						for ai, a := range t.Actions {
							values = append(
								values,
								root.ActionArg(ci, oi, ti, ai),
								fmt.Sprintf("%s: %s", a.Name, t.Description),
							)
						}
					}
				}
			}
			return carapace.ActionValuesDescribed(
				values...,
			).Cache(30*time.Second).Invoke(c).ToMultiPartsA("/", ":")
		}),
	)
}
