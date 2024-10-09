# ChroQueTas
*<ins>Chro</ins>mosome <ins>Que</ins>ry <ins>Ta</ins>rget<ins>s</ins> </ins>*

\* *Repository under development*

## Table of contents
1. [Introduction](#id1)
2. [Instructions](#id2)
3. [Installation](#id3)
4. [Example usage](#id4)
5. [Citation](#id5)

## 1. Introduction<a name="id1"></a>

ChroQueTas (*<ins>Chro</ins>mosome <ins>Que</ins>ry <ins>Ta</ins>rget<ins>s</ins> </ins>*) is a user-friendly software that would allow you to dientify **RAM in fungal genomes**. 


## 2. Instructions<a name="id2"></a>

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

## 3. Installation<a name="id3"></a>

### 2.1 Via conda

```bash
conda install nmquijada::chroquetas
```

### 2.2 Via docker

The docker container can be build using

```shell
# Download repository
git clone https://github.com/nmquijada/ChroQueTas.git
docker build .
```

### 2.3 Via source code

```bash
# Install dependencies
conda install bioconda::blast bioconda::mafft miniprot

# Download repository
git clone https://github.com/nmquijada/ChroQueTas.git # while repo is private manual download is required
chmod 700 ChroQueTas/bin/ChroQueTas.sh
```

<br>

## 4. Example usage<a name="id4"></a>

Test ChroQueTas with a *Zymoseptoria tritici* genome (SRR751313):

```bash
./ChroQueTas/bin/ChroQueTas.sh -f ChroQueTas/db -g ChroQueTas/test_dataset/SRR7513134.fasta.gz -o test -s Ztritici -t 8
```

For the docker container, usage is similar

```bash
docker run <image name> -f db -g test_dataset/SRR7513134.fasta.gz -o test -s Ztritici
```
<br>

## 5. Citation<a name="id5"></a>

ChroQueTas has been sumbitted for publication together with the FungAMR database.
In the meantime, if you are using ChroQueTas (https://github.com/nmquijada/ChroQueTas) and/or FungAMR (https://github.com/Landrylab/FungAMR), please cite them as:

Bedard, C. et al. FungAMR: A comprehensive portrait of antimicrobial resistance mutations in fungi. bioRxiv, doi: [https://doi.org/10.1101/2024.10.07.617009](https://www.biorxiv.org/content/10.1101/2024.10.07.617009v1)
