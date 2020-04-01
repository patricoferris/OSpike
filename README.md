OSpike
--------------

![](https://github.com/patricoferris/ospike/workflows/ospike/badge.svg)

OCaml spike is a command line tool for analysing Spike (RISC-V ISA Simulator) dynamic instruction logs. Since the logs can be large it is recommended to 
pipe the output into the command line tool to analyse in parallel the instruction stream. 

From the root directory you can build and install the CLI tool simply by running: 

```
dune build 
dune install 
```

Some of the options for configuring what the tool does includes (`ospike -help`): 

```
🐫  OSpike - a tool for parsing Spike logs with OCaml  🐫

  ospike [mode - <stdin|file>]

=== flags ===

  [-compare mode]       how to compare instructions - default is without
                        registers, any other string will use registers
  [-group size]         the size of the groups of adjacent instructions to look
                        at (default 1)
  [-lower lower-bound]  on the address range to include in the stats (yet to be
                        implemented)
  [-o filename]         location for the results to be stored
  [-upper upper-bound]  on the address range to include in the stats (yet to be
                        implemented)
  [-build-info]         print info about this build and exit
  [-version]            print the version of this build and exit
  [-help]               print this help text and exit
                        (alias: -?)
```

 (🆁🅸🆂🅲-🆅 + 🐪)