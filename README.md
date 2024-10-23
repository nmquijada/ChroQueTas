# ChroQueTas
*<ins>Chro</ins>mosome <ins>Que</ins>ry <ins>Ta</ins>rget<ins>s</ins> </ins>*

\* *Repository under development*

> The current version of the repository contains the software as it was used for the analysis of 46 *Candida albicans* and 144 *Zymoseptoria tritici* genomes as described in the [preprint](https://www.biorxiv.org/content/10.1101/2024.10.07.617009v1).
> 
> **PLEASE NOTE** that the potential AMR mutations detected by ChroQueTas are reported as "**FungAMR MUTATION**" and they **must** be checked with the [FungAMR database](https://github.com/Landrylab/FungAMR) in order to infer their level of evidence. The level of evidence for each mutation will be included in the pipeline soon so it will be automatically reported by ChroQueTas.

<br>

## Table of contents
1. [Introduction](#id1)
2. [Instructions](#id2)
3. [Installation](#id3)
4. [Example usage](#id4)
5. [Citation](#id5)

<br>

## 1. Introduction<a name="id1"></a>

ChroQueTas (*<ins>Chro</ins>mosome <ins>Que</ins>ry <ins>Ta</ins>rget<ins>s</ins> </ins>*) is a user-friendly software that would allow you to dientify **antimicrobial resistance in fungal genomes**.

ChroQueTas works in combination to [FungAMR](https://github.com/Landrylab/FungAMR), an outsanding resource for antimicrobial resistance (AMR), that contains 54,666 mutation entries (all classified with the degree of evidence that supports their role in resistance), covering 92 species, 202 genes and 184 fungicides. FungAMR and ChroQueTas have been submitted for publication, where you could read the [preprint](https://www.biorxiv.org/content/10.1101/2024.10.07.617009v1). You can download the whole FungAMR resource from [it's main GitHub repository](https://github.com/Landrylab/FungAMR) and also the formatted one when downloading and installing ChroQueTas.  

With that information contained in [FungAMR](https://github.com/Landrylab/FungAMR), ChroQueTas will:   

- i) extract from the fungal genome the CDS and protein where a point mutation is known to cause AMR in that particular species by using miniprot v0.12-r23750 and the information contained in FungAMR.  
- ii) evaluate sequence similarity against the reference by using BLASTP and discard low confidence hits (to be specified by the user and the `--min_id`, `--min_cov` flags)
- iii) deal with potential introns, exons and InDels
- iv) evaluate amino acid positions between the query and the reference proteins accounting for FungAMR information
- v) report amino acid changes and InDels that could lead to AMR according to the confidence score in FungAMR

<br> 

## 2. Instructions<a name="id2"></a>

```
OBLIGATORY OPTIONS:
    -f/--fungamr        Path to FungAMR database formatted for ChroQueTas
    -g/--genome         Path to the genomes file
    -o/--output         Path and name of the output directory
    -s/--scheme         Type the scheme you would like to conduct the analysis on
                        Options available: 'Calbicans', 'Ztritici'

OTHER OPTIONS:
    --min_cov           Sequence alignment coverage (percent) required for the target protein to be considered (default=75) <integer>
    --min_id            Sequence alignment similarity (percent) required for the target protein to be considered (default=75) <integer>
    -t/--threads        Number of threads to use (default=1) <integer>
    -v/--version        Show version
```

<br>

## 3. Installation<a name="id3"></a>

> Right now, only installation via source code is available. A conda package and docker container are being prepared and will be released asap

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

Test ChroQueTas with a *Zymoseptoria tritici* genome (SRR7513134):

```bash
./ChroQueTas/bin/ChroQueTas.sh -f ChroQueTas/db -g ChroQueTas/test_dataset/SRR7513134.fasta.gz -o test -s Ztritici -t 8
```

For the docker container, usage is similar (not available yet)

```bash
docker run <image name> -f db -g test_dataset/SRR7513134.fasta.gz -o test -s Ztritici
```
<br>

## 5. Citation<a name="id5"></a>

ChroQueTas has been sumbitted for publication together with the FungAMR database. 
In the meantime, if you are using ChroQueTas (https://github.com/nmquijada/ChroQueTas) and/or FungAMR (https://github.com/Landrylab/FungAMR), please cite them as:

Bédard, C. et al. FungAMR: A comprehensive portrait of antimicrobial resistance mutations in fungi. bioRxiv, doi: [https://doi.org/10.1101/2024.10.07.617009](https://www.biorxiv.org/content/10.1101/2024.10.07.617009v1)
