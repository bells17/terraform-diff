package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"github.com/hashicorp/terraform/terraform"
	"github.com/hashicorp/terraform/version"
	"github.com/hashicorp/terraform/command/format"
	"github.com/jessevdk/go-flags"
	"os"
	"runtime"
)

var BuildVersion string

type Options struct {
	Version bool `short:"v" long:"version" description:"print version"`
}

func main() {
	opts, args := getOptions()
	if opts.Version {
		printVersion()
		os.Exit(0)
	}

	if len(args) == 0 {
		fmt.Fprint(os.Stderr, "Path argument is required")
		os.Exit(1)
	}

	plan, err := readPlan(args[0])
	if err != nil {
		fmt.Fprint(os.Stderr, fmt.Sprintf("%s\n", err))
		os.Exit(1)
	}

	// diffJson, diffErr := json.MarshalIndent(plan.Diff, "", "\t")
	// if diffErr == nil {
	// 	fmt.Print(string(diffJson))
	// }

	dispPlan := format.NewPlan(plan)
	diffJson, diffErr := json.MarshalIndent(dispPlan, "", "\t")
	if diffErr == nil {
		fmt.Print(string(diffJson))
	}
}

func readPlan(path string) (*terraform.Plan, error) {
	f, err := os.Open(path)
	if err != nil {
		return nil, errors.New(fmt.Sprintf("Error loading file - %s", err))
	}
	defer f.Close()

	plan, err := terraform.ReadPlan(f)
	if err != nil {
		if _, err := f.Seek(0, 0); err != nil {
			return nil, errors.New(fmt.Sprintf("Error reading file - %s", err))
		}
	}
	return plan, nil
}

func getOptions() (Options, []string) {
	opts := Options{}
	psr := flags.NewParser(&opts, flags.Default)
	args, err := psr.Parse()
	if err != nil {
		fmt.Fprintf(os.Stderr, "%s\n", err)
		os.Exit(1)
	}
	return opts, args
}

func printVersion() {
	fmt.Printf(`terraform-diff %s
Terraform-Version: %s
Compiler: %s %s
`,
		BuildVersion,
		version.String(),
		runtime.Compiler,
		runtime.Version())
}
