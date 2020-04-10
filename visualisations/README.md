Visualisations 
--------------

Plotting library which takes certain kinds of output from `ospike` and visualises them to make sense of the instruction stream. 

- Heatmap: a heatmap of the most common pairs of instructions can be plotted. To get the right output from `ospike` make sure to run the following command `ospike stdin -group 2` which uses the default instruction name only comparison. 
- Frequency plot: draws the graph for a single instruction count (make sure the group size is 1).