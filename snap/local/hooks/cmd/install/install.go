// -*- Mode: Go; indent-tabs-mode: t -*-

/*
 * Copyright (C) 2021 Canonical Ltd
 *
 *  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except
 *  in compliance with the License. You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License
 * is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
 * or implied. See the License for the specific language governing permissions and limitations under
 * the License.
 *
 * SPDX-License-Identifier: Apache-2.0'
 */

package main

import (
	"fmt"
	"os"
	"os/exec"

	hooks "github.com/canonical/edgex-snap-hooks/v2"
)

var cli *hooks.CtlCli = hooks.NewSnapCtl()

// installKuiper execs a shell script to install Kuiper's file into $SNAP_DATA
func installKuiper() error {
	setupScriptPath, err := exec.LookPath("install-setup-kuiper.sh")
	if err != nil {
		return err
	}

	cmdSetupKuiper := exec.Cmd{
		Path:   setupScriptPath,
		Args:   []string{setupScriptPath},
		Stdout: os.Stdout,
		Stderr: os.Stdout,
	}

	stdoutStderr, err := cmdSetupKuiper.CombinedOutput()
	if err != nil {
		hooks.Error(fmt.Sprintf("edgex-ekuiper:install: Kuiper's file installation failure: %v", err))
	} else {
		hooks.Info(fmt.Sprintf("edgex-ekuiper:install: Kuiper's file installation success: %v", stdoutStderr))
	}

	return nil
}

func main() {
	var err error

	if err = hooks.Init(false, "edgex-kuiper"); err != nil {
		hooks.Info(fmt.Sprintf("edgex-kuiper:install: initialization failure: %v", err))
		os.Exit(1)
	}

	if err = installKuiper(); err != nil {
		hooks.Error(fmt.Sprintf("edgex-kuiper:install: %v", err))
		os.Exit(1)
	}
}
