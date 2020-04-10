import matplotlib.pyplot as plt 
import numpy as np 
import seaborn as sns 
import pandas as pd 

filepath = '/Users/patrickferris/scratch/log/pattern-single.ospike'


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


def frequency_plot(instructions):
  df = pd.DataFrame.from_records(instructions, columns =['instruction', 'frequency'])
  fig, ax = plt.subplots(figsize=(12, 9))
  ax.plot(df['instruction'], df['frequency'])
  plt.xticks(rotation=45)
  fig.savefig("o.png")

def heatmap(instructions): 
  df = pd.DataFrame.from_records(instructions, columns =['Instruction_One', 'Instruction_Two', 'Frequency'])
  result = df.pivot(index='Instruction_One', columns='Instruction_Two', values='Frequency').fillna(0)
  svm = sns.heatmap(result, fmt="g", cmap='viridis')
  svm.get_figure().savefig('out.png')


with open(filepath) as fp:
  header = fp.readline()
  line = fp.readline()
  instructions = [] 
  while line:
    add_to_instruction(instructions, parse_single_instruction(line))
    line = fp.readline()
  frequency_plot(instructions)
  
  