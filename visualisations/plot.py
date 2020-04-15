import matplotlib as mpl
import matplotlib.pyplot as plt 
import numpy as np 
import seaborn as sns 
import pandas as pd 
import os 
import sys

from functools import reduce


# Nicer graphs - taken from https://jwalton.info/Embed-Publication-Matplotlib-Latex/
default_width = 460
def set_size(width, fraction=1):
  """ Set figure dimensions to avoid scaling in LaTeX.

  Parameters
  ----------
  width: float
          Document textwidth or columnwidth in pts
  fraction: float, optional
          Fraction of the width which you wish the figure to occupy

  Returns
  -------
  fig_dim: tuple
          Dimensions of figure in inches
  """
  # Width of figure (in pts)
  fig_width_pt = width * fraction

  # Convert from pt to inches
  inches_per_pt = 1 / 72.27

  # Golden ratio to set aesthetic figure height
  golden_ratio = (5**.5 - 1) / 2

  # Figure width in inches
  fig_width_in = fig_width_pt * inches_per_pt
  # Figure height in inches
  fig_height_in = fig_width_in * golden_ratio

  fig_dim = (fig_width_in, fig_height_in)

  return fig_dim

nice_fonts = {
  # Use LaTeX to write all text
  "text.usetex": True,
  "font.family": "sans-serif",
  # Use 10pt font in plots, to match 10pt font in document
  "axes.labelsize": 10,
  "font.size": 12,
  # Make the legend/label fonts a little smaller
  "legend.fontsize": 8,
  "xtick.labelsize": 8,
  "ytick.labelsize": 8,
}

mpl.rcParams.update(nice_fonts)

# Graph generating functions
def parse_instruction_pair(line): 
  instrs = line.strip().split(")(")
  if len(instrs) > 1:
    first = instrs[0][1:]
    
    snd_count = instrs[1].split(")")
    snd = snd_count[0]
    count = snd_count[1][2:]
    return (first, snd, int(count))

def parse_single_instruction(line): 
  ins = line.strip().split(": ")
  if ins != None and len(ins) > 1:
    if ins[0] != 'Unknown Instruction' and len(ins[0]) <= 10:
      return (ins[0][1:-1], int(ins[1]))


def add_to_instruction(lst, ins): 
  if ins != None:
    if ins[0] != 'Unknown Instruction' and ins[1] != 'Unknown Instruction':
      lst.append(ins)

def frequencies_plot(instr_dict, first_n=None, title="", xtitle="", ytitle=""): 
  plt.style.use('science')
  fig, ax = plt.subplots(figsize=set_size(default_width))
  for key in instr_dict: 
    df = pd.DataFrame.from_records(instr_dict[key], columns =['instruction', 'frequency'])
    if first_n != None:
      ax.scatter(df['instruction'][:first_n], df['frequency'][:first_n], label=key, s=6)
    else: 
      ax.scatter(df['instruction'], df['frequency'], label=key)
  plt.xticks(rotation=45)
  ax.legend()
  plt.title(title)
  plt.xlabel(xtitle)
  plt.ylabel(ytitle)
  fig.savefig("original-riscv.pdf", format='pdf', bbox_inches='tight')

def frequency_plot(instructions):
  df = pd.DataFrame.from_dict(instructions, columns=['instruction', 'frequency'])
  print(df)
  fig, ax = plt.subplots(figsize=(12, 9))
  ax.plot(df['instruction'], df['frequency'])
  plt.xticks(rotation=45)
  fig.savefig("original-riscv-fq.pdf", format='pdf', bbox_inches='tight')

def heatmap(instructions, title="", first_n=10): 
  df = pd.DataFrame.from_records(instructions[:first_n], columns =['Instruction One', 'Instruction Two', 'Frequency'])
  result = df.pivot(index='Instruction One', columns='Instruction Two', values='Frequency').fillna(0)
  fig, ax = plt.subplots(figsize=set_size(default_width))
  sns.heatmap(result, ax=ax, fmt="g", cmap='YlOrRd')
  plt.title(title)
  fig.savefig('heat.pdf', format='pdf', bbox_inches='tight')

def instructions(filepath, parse_pair=False, normalise=False):
  with open(filepath) as fp:
    header = fp.readline()
    line = fp.readline()
    instructions = [] 
    while line:
      if parse_pair: 
        add_to_instruction(instructions, parse_instruction_pair(line))
      else:
        add_to_instruction(instructions, parse_single_instruction(line))
      line = fp.readline()
    if normalise: 
      total = 0
      for (i, c) in instructions:
        total += c 
      for i in range(len(instructions)): 
        instructions[i] = (instructions[i][0], instructions[i][1] / total)
    return instructions
  
def multiple_plot(filepaths, noramlise_all=False): 
  all_instructions = {}
  for filepath in filepaths: 
    all_instructions[os.path.basename(filepath).split("-")[0]] = instructions(filepath, normalise=True)
  insn = {} 
  if noramlise_all == True: 
    instruction_amount = {}
    total = 0 
    for key in all_instructions: 
      for ins, val in all_instructions[key]:
        total += val 
        if ins not in instruction_amount:
          insn[ins] = val 
          instruction_amount[ins] = 1
        else:
          insn[ins] += val
          instruction_amount[ins] += 1
    for key in insn:
      insn[key] = insn[key] / instruction_amount[key]
    frequency_plot(
      insn
    )
  else:
    n = 16
    frequencies_plot(
      all_instructions, 
      first_n=n,
      title="Top " + str(n) + " most frequent instructions for RISC-V test cases",
      xtitle="Instruction names",
      ytitle="Proportion of instructions per program per instruction"
    )

# For heatmap
filepath = '/Users/patrickferris/scratch/log/pattern-compare-utils.ospike'
  
# For multiple files
files = [
  "/Users/patrickferris/scratch/log/uncomp/gc-original-riscv.log",
  "/Users/patrickferris/scratch/log/uncomp/intfloatarray-original-riscv.log",
  "/Users/patrickferris/scratch/log/uncomp/pattern-original-riscv.log",
  "/Users/patrickferris/scratch/log/uncomp/someornone-original-riscv.log",
  "/Users/patrickferris/scratch/log/uncomp/sorting-original-riscv.log",
  "/Users/patrickferris/scratch/log/uncomp/zerotypes-original-riscv.log"
]

if len(sys.argv) < 1:
  print("Please provide multiple or heatmap")
else:
  if sys.argv[1] == "multiple":
    multiple_plot(files, noramlise_all=True)
  else:
    insn = instructions(filepath, parse_pair=True)
    heatmap(insn, title="A heatmap of pairs of instructions for \\texttt{pattern.ml}", first_n=30)


  
  