ospike
--------------

OCaml spike is a command line tool for analysing Spike (RISC-V ISA Simulator) dynamic instruction logs. Since the logs can be large it is recommended to 
pipe the output into the command line tool to analyse in parallel the instruction stream. 

Some of the options for configuring what the tool does includes: 

 - `-o <filename>` will output the results to file with that name. 
 - `-lower <int>` and `-upper <int>` specify the inclusive addresses to not ignore when analysing the dynamic instruction stream. 
 - `-common <int>` when this is set the tool will look at the most common groupings of adjacent instructions and output them. For now this is done by matching the name.  