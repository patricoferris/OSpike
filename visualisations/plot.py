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

def heatmap(instructions, file='heat.pdf', title="", first_n=10): 
  df = pd.DataFrame.from_records(instructions[:first_n], columns =['Instruction One', 'Instruction Two', 'Frequency'])
  result = df.pivot(index='Instruction One', columns='Instruction Two', values='Frequency').fillna(0)
  fig, ax = plt.subplots(figsize=set_size(default_width))
  sns.heatmap(result, ax=ax, fmt="g", cmap='YlOrRd')
  plt.title(title)
  fig.savefig(file, format='pdf', bbox_inches='tight')

def get_total(filepath):
  with open(filepath) as fp:
    header = fp.readline()
    line = fp.readline()
    while line:
      if "Total Number of Instructions" in line: 
        return int(line.split(": ")[1])
      line = fp.readline()

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

def compare_plot(comp_dict, title="", xlabel="", filename="", y_bottom=0.99): 
  og = []
  mod = []
  inline = []
  files = []
  for key in comp_dict: 
    files.append(key)
    print(files)
    ogg = get_total(comp_dict[key][0])
    oc = get_total(comp_dict[key][1])
    inl = get_total(comp_dict[key][2])
    og.append(1)
    mod.append(oc / ogg)
    inline.append(inl / ogg)
  fig, ax = plt.subplots(figsize=set_size(default_width))
  w=0.2
  ids = np.arange(len(og))
  ax.set_ylim(bottom=y_bottom, top=1.002)
  ax.bar(ids-w, og, width=w, align='center', label='original')
  ax.bar(ids,   mod, width=w, align='center', label='rv64GO')
  ax.bar(ids+w, inline, width=w, align='center', label='rv64GO+inline')  
  ax.axhline(1.0, color='orange', ls='--')
  ax.legend()
  plt.xticks(ticks=ids, labels=files)
  plt.title(title)
  plt.xlabel(xlabel)
  plt.ylabel("Dynamic Instructions (normalised to unmodified compiler)")
  fig.savefig(filename + '.pdf', format='pdf', bbox_inches='tight')

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
# filepath = '/Users/patrickferris/scratch/log/pattern-compare-utils.ospike'
filepath = '/Users/patrickferris/scratch/log/yojson-original/yj-comp-stdlibend.log'
# For multiple files
files = [
  "/Users/patrickferris/scratch/log/uncomp/gc-original-riscv.log",
  "/Users/patrickferris/scratch/log/uncomp/intfloatarray-original-riscv.log",
  "/Users/patrickferris/scratch/log/uncomp/pattern-original-riscv.log",
  "/Users/patrickferris/scratch/log/uncomp/someornone-original-riscv.log",
  "/Users/patrickferris/scratch/log/uncomp/sorting-original-riscv.log",
  "/Users/patrickferris/scratch/log/uncomp/zerotypes-original-riscv.log"
]

compare = {
  "gc" : [
    "/Users/patrickferris/scratch/log/final/cross-original.riscv/riscv/gc.log",
    "/Users/patrickferris/scratch/log/final/cross.riscv/riscv/gc.log",
    "/Users/patrickferris/scratch/log/final/cross-inline.riscv/riscv/gc.log",
  ],
  "intfloatarray" : [
    "/Users/patrickferris/scratch/log/final/cross-original.riscv/riscv/intfloatarray.log",
    "/Users/patrickferris/scratch/log/final/cross.riscv/riscv/intfloatarray.log",
    "/Users/patrickferris/scratch/log/final/cross-inline.riscv/riscv/intfloatarray.log",
  ],
  "pattern" : [
    "/Users/patrickferris/scratch/log/final/cross-original.riscv/riscv/pattern.log",
    "/Users/patrickferris/scratch/log/final/cross.riscv/riscv/pattern.log",
    "/Users/patrickferris/scratch/log/final/cross-inline.riscv/riscv/pattern.log",
  ],
  "someornone" : [
    "/Users/patrickferris/scratch/log/final/cross-original.riscv/riscv/someornone.log",
    "/Users/patrickferris/scratch/log/final/cross.riscv/riscv/someornone.log",
    "/Users/patrickferris/scratch/log/final/cross-inline.riscv/riscv/someornone.log",
  ],
  "sorting" : [
    "/Users/patrickferris/scratch/log/final/cross-original.riscv/riscv/sorting.log",
    "/Users/patrickferris/scratch/log/final/cross.riscv/riscv/sorting.log",
    "/Users/patrickferris/scratch/log/final/cross-inline.riscv/riscv/sorting.log",
  ],
  "zerotypes" : [
    "/Users/patrickferris/scratch/log/final/cross-original.riscv/riscv/zerotypes.log",
    "/Users/patrickferris/scratch/log/final/cross.riscv/riscv/zerotypes.log",
    "/Users/patrickferris/scratch/log/final/cross-inline.riscv/riscv/zerotypes.log",
  ],
}

compare_fft = {
  "fft" : [
    "/Users/patrickferris/scratch//log/cross-original-num/fft.log",
    "/Users/patrickferris/scratch//log/cross-num/fft.log",
    "/Users/patrickferris/scratch//log/cross-inline-num/fft.log",
  ]
}

compare_oclea = {
  "gc" : [
    "/Users/patrickferris/scratch/log/final-oclea-riscv-original/gc.log",
    "/Users/patrickferris/scratch/log/final-oclea-riscv/gc.log",
    "/Users/patrickferris/scratch/log/final-oclea-riscv-inline/gc.log",
  ],
  "intfloatarray" : [
    "/Users/patrickferris/scratch/log/final-oclea-riscv-original/intfloatarray.log",
    "/Users/patrickferris/scratch/log/final-oclea-riscv/intfloatarray.log",
    "/Users/patrickferris/scratch/log/final-oclea-riscv-inline/intfloatarray.log",
  ],
  "pattern" : [
    "/Users/patrickferris/scratch/log/final-oclea-riscv-original/pattern.log",
    "/Users/patrickferris/scratch/log/final-oclea-riscv/pattern.log",
    "/Users/patrickferris/scratch/log/final-oclea-riscv-inline/pattern.log",
  ],
  "someornone" : [
    "/Users/patrickferris/scratch/log/final-oclea-riscv-original/someornone.log",
    "/Users/patrickferris/scratch/log/final-oclea-riscv/someornone.log",
    "/Users/patrickferris/scratch/log/final-oclea-riscv-inline/someornone.log",
  ],
  "sorting" : [
    "/Users/patrickferris/scratch/log/final-oclea-riscv-original/sorting.log",
    "/Users/patrickferris/scratch/log/final-oclea-riscv/sorting.log",
    "/Users/patrickferris/scratch/log/final-oclea-riscv-inline/sorting.log",
  ],
  "zerotypes" : [
    "/Users/patrickferris/scratch/log/final-oclea-riscv-original/zerotypes.log",
    "/Users/patrickferris/scratch/log/final-oclea-riscv/zerotypes.log",
    "/Users/patrickferris/scratch/log/final-oclea-riscv-inline/zerotypes.log",
  ],
}

if len(sys.argv) < 1:
  print("Please provide multiple or heatmap")
else:
  if sys.argv[1] == "multiple":
    multiple_plot(files, noramlise_all=True)
  elif sys.argv[1] == "compare": 
    compare_plot(compare, filename="final", y_bottom=0.95)
  else:
    insn = instructions(filepath, parse_pair=True)
    heatmap(insn, file="heat-yj.pdf", title="A heatmap of pairs of instructions for \\texttt{pattern.ml}", first_n=30)


  
  