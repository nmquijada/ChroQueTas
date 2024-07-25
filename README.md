# ChroQueTas
*<ins>Chro</ins>mosome <ins>Que</ins>ry <ins>Ta</ins>rget<ins>s</ins> </ins>*

\* *Repository under development*

## Table of contents
1. [Introduction](#id1)
2. [Installation](#id2)
3. [Example usage](#id3)

## 1. Introduction<a name="id1"></a>

Instructions:

```
OBLIGATORY OPTIONS:
    -f/--fungamr        Path to FungAMR database formatted for ChroQueTas
    -g/--genome         Path to the genomes file
    -o/--output         Path and name of the output directory
    -s/--scheme         Type the scheme you would like to conduct the analysis on
                        Options available: 'Calbicans', 'Ztritici'

OTHER OPTIONS:
    -t/--threads        Number of threads to use (default=1) <integer>
    -v/--version        Show version
```

<br>

## 2. Installation<a name="id2"></a>

```bash
# Install dependencies
conda install bioconda::blast bioconda::mafft miniprot

# Download repository
git clone https://github.com/nmquijada/ChroQueTas.git # while repo is private manual download is required
chmod 700 ChroQueTas/bin/ChroQueTas.sh
```

<br>

## 3. Example usage<a name="id2"></a>

Test example with a *Zymoseptoria tritici* genome and Cyp51 protein  

```bash
./ChroQueTas/bin/ChroQueTas.sh -f ChroQueTas/db -g ChroQueTas/test_dataset/SRR7513134.fasta.gz -o test -s Ztritici -t 8
```
<br>
