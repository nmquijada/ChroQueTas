[![Anaconda-Server Badge](https://anaconda.org/nmquijada/chroquetas/badges/version.svg)](https://anaconda.org/nmquijada/chroquetas)
[![Anaconda-Server Badge](https://anaconda.org/nmquijada/chroquetas/badges/latest_release_date.svg)](https://anaconda.org/nmquijada/chroquetas)
<br>

# ChroQueTas

*<ins>Chro</ins>mosome <ins>Que</ins>ry <ins>Ta</ins>rget<ins>s</ins> </ins>*  

A user-friendly software to perform fungicide resistance screening in fungal genomes  

<br>

## UPDATE! ChroQueTas v0.6.0 is out! (2025-05-08)
- Increased FungAMR database with 57 species, 210 proteins and a total of 8,285 mutations associated with AMR (more info can be extracted by using --list_species flag)
- Included novel function from `miniprot` that allows choosing the genetic code for translation. The genetic code can be manually selected by the user and the -c/--trans_code flag. By default, the genetic code is automatically set by ChroQueTas according to the -s/--species flag (formerly --scheme, but renamed to avoid [confusions](https://github.com/nmquijada/ChroQueTas/issues/3)), so it would be set to "alternative yeast code" (-c 12) for the species within the CTG clade or to the "standard code" (-c 1) for the other species. You can inspect the default behavior [here](https://raw.githubusercontent.com/nmquijada/ChroQueTas/refs/heads/v0.6.0/files/FungAMR_genetic_code.txt)
- Reporting of AMR based on the "confidence score" per mutation, as described in the preprint. Learn more about teh confidence score in the [wiki](https://github.com/nmquijada/ChroQueTas/wiki/Confidence-score-for-antimicrobial-resistance)
- Extended outputs, as described [here](#id5)
- New [preprint](https://www.biorxiv.org/content/10.1101/2024.10.07.617009v2) available.

<br>

## Table of contents
<img align="right" src="https://github.com/nmquijada/ChroQueTas/blob/images/temprorary_CQTs_logo_AJA.jpeg" width="20%">

1. [Introduction](#id1)
2. [Instructions](#id2)
3. [Installation](#id3)
4. [Example usage](#id4)
5. [Expected output](#id5)
6. [Citation](#id6)
7. [License](#id7)

<br>

## 1. Introduction<a name="id1"></a>

**ChroQueTas** (*<ins>Chro</ins>mosome <ins>Que</ins>ry <ins>Ta</ins>rget<ins>s</ins> </ins>*) is a quick and user-friendly software that would allow you to dientify **antimicrobial resistance in fungal genomes** in just a matter of seconds! You just need to provide a fungal genome (in FASTA format, can be gz-compressed) and to set some minimal options.

ChroQueTas works in combination to **[FungAMR](https://card.mcmaster.ca/fungamrhome)**, an outsanding resource for fungicide resistance  that contains 54,666 mutation entries (all classified with the degree of evidence that supports their role in resistance), covering 92 species, 202 genes and 184 fungicides. FungAMR and ChroQueTas have been submitted for publication, where you could read the [preprint](https://www.biorxiv.org/content/10.1101/2024.10.07.617009v2).  

You can screen the **FungAMR** database interactively from its main [web page](https://card.mcmaster.ca/fungamrhome) or download the full content from its [main GitHub repository](https://github.com/Landrylab/FungAMR). The content from FungAMR is also downloaded and formatted automatically when installing ChroQueTas.  

With that information contained in [FungAMR](https://github.com/Landrylab/FungAMR), ChroQueTas will:   

- i) extract from the fungal genome the CDS and protein where a point mutation is known to cause AMR in that particular species by using miniprot (v.0.14-r265) and the information contained in FungAMR.  
- ii) evaluate sequence similarity against the reference by using BLASTP (v2.14.1+) and discard low confidence hits (to be specified by the user and the `--min_id`, `--min_cov` flags)
- iii) deal with potential introns, exons and InDels
- iv) evaluate amino acid positions between the query and the reference proteins accounting for FungAMR information
- v) report amino acid changes and InDels that could lead to AMR according to the confidence score in FungAMR

<br> 

## 2. Instructions<a name="id2"></a>


> The instructions belong to v0.6.0. For older versions please check the [releases page](https://github.com/nmquijada/ChroQueTas/releases)


ChroQueTas only requires a fungal genome to work (to be specified with `-g/--genome`), the the species of the genome to be investigated (`-s/--species`) and the desired output directory name (`-o/--output`, ChroQueTas will create the output and will generate all the files there, as explained [here](#id5)).   

You can list the species and proteins available by typing: `ChroQueTas.sh --list_species`  

```
OBLIGATORY OPTIONS:
    -f/--fungamr        Path to FungAMR database formatted for ChroQueTas
    -g/--genome         Path to the genome file
    -o/--output         Path and name of the output directory
    -s/--species        Type the species you would like to conduct the analysis on
                        To inspect the pecies and proteins available use the '--list_species' flag

OTHER OPTIONS:
    -c/--trans_code     Specify number for Genetic Code to be used for protein translation, if needed (default= "12" for CTG clade and "1" for other fungi)
    -f/--fungamr        Path to FungAMR database formatted for ChroQueTas
    --list_species      Provides the list of species and proteins that can be screened with ChroQueTas
    --min_cov           Sequence alignment coverage (percent) required for the target protein to be considered (default=75) <integer>
    --min_id            Sequence alignment similarity (percent) required for the target protein to be considered (default=75) <integer>
    -t/--threads        Number of threads to use (default=1) <integer>
    -v/--version        Show version
```

<br> 

> Please note: If a genetic code is not specified (`-c/--trans_code`), ChroQueTas will set this option automatically to the "alternative yeast code" (`-c 12`) for the species within the CTG clade or to the "standard code" (`-c 1`) for the other species. You can inspect the default behaviour [here](https://raw.githubusercontent.com/nmquijada/ChroQueTas/refs/heads/v0.6.0/files/FungAMR_genetic_code.txt).

<br>

You can see an example of ChroQueTas usage in [this section](#id4)

<br>

## 3. Installation<a name="id3"></a>

ChroQueTas has been built and tested on Linux Debian, Ubuntu and Mint; under environments with python version 3.8 and 3.9.   

### 3.1 Via conda (recommended)

```bash
conda install -c nmquijada chroquetas=0.6
# force the latest version
````

In case you find issues with the channels, try first:

```bash
conda config --add channels nmquijada
conda config --set channel_priority disabled
```

### 3.2 Via source code

```bash
# Install dependencies
conda install bioconda::blast bioconda::mafft miniprot

# Download repository
git clone https://github.com/nmquijada/ChroQueTas.git
chmod 700 ChroQueTas/bin/ChroQueTas.sh 
tar zxvf ChroQueTas/FungAMR_db.tgz
# Clean the house (optional)
rm -r ChroQueTas/FungAMR_db.tgz
```

<br>

## 4. Example usage<a name="id4"></a>

You can test ChroQueTas with different *Candida albicans* and *Zymoseptoria tritici* genomes included in the `test_dataset` directory.  

ChroQueTas has been built and tested on different Linux OS (Debian, Ubuntu and Mint) and hardware infraestructure (including laptop 16GB RAM, 8 CPUs; and servers 124GB RAM 20 CPUs, 1TB RAM 128 CPUs & 2TB RAM, 254 CPUs). **The running time per genome was a few seconds in all cases** (time is gold).  

<br>

```bash
## Candida albicans
ChroQueTas.sh -g test_dataset/Calbicans_SRR13587609.fasta.gz -s Candida_albicans -c 12 --min_id 75 --min_cov 75 -t 2 -o Calbicans_SRR13587609_ChroQueTas

## Zymoseptoria tritici
ChroQueTas.sh -g test_dataset/Ztritici_SRR4907747.fasta.gz -s Zymoseptoria_tritici -c 1 --min_id 75 --min_cov 75 -t 2 -o Ztritici_SRR4907747_ChroQueTas 
```

<br>

## 5. Expected output<a name="id5"></a>

ChroQueTas will look in the genome for the different fungicide-target proteins available for the different species (see [here](https://github.com/nmquijada/ChroQueTas/tree/main/db)). For each of the proteins, ChroQueTas will generate:  

- **Summary of the results** (`name.ChroQueTaS.AMR_summary.txt`): tabular file containing a summary of those mutations found in the proteins of the genome associated with fungicide resistance, together with the level of evidence associated to the different fungicides it confer resistance to (or not).
- **Overall statistics**: tabular file (`name.ChroQueTaS.AMR_stats.txt`) containing the different proteins available for screening in that particular species and the number of mutations (either reported in FungAMR or not) identified in those particular positions of the protein previously reported to confer fungicide resistance.
- **Results file per protein** (`name.ChroQueTas.protein.tsv`): a tabular file were every single amino acid position included in [FungAMR](https://github.com/Landrylab/FungAMR) is reported together with the amino acid occurring in both the reference and the query genomes. The field `Results` could report the following:
    - `No mutation`: absence of mutation according to reference
    - `FungAMR mutation`: mutation occuring in the query genome and also reported in FungAMR. When a `FungAMR` mutation is reported, the field `Fungicides` states the fungicides for which this mutation has an associated resistance. The mutation should be checked in the database to confirm the level of evidence, as not all mutations confer AMR (*we are working to include the level of evidence directly in ChroQueTas output*).
    - `New mutation`: mutation occuring in the query genome but not reported in FungAMR. This mutation happens in a position previously described to confer resistance but the amino acid change does not match. This could mean a potential novel resistance, but would require further investigation.
- **Extracted protein from query** (`name.ChroQueTas.protein.faa`): amino acid FASTA file containing the sequence of the target protein extracted from the genome.
- **Pairwise Mapping file** (in PAF format, `name.ChroQueTas.protein.paf`): contains the alignment information between query and reference. Contig/Chromosome name and positions where the target protein was predicted can be extracted from this file (fields 6-9).
- **BLASTP alignment between reference and extracted query protein** (`name.ChroQueTas.protein.txt`): Alignment results between the query and reference proteins. Only those alignments overcoming the `--min_id` and `--min_cov` provided values are reported here.
- `tmp` directory containing all the intermediatefiles generated during the analysis


<br>

## 6. Citation<a name="id6"></a>

ChroQueTas has been sumbitted for publication together with the FungAMR database. 
In the meantime, if you are using ChroQueTas (https://github.com/nmquijada/ChroQueTas) and/or FungAMR (https://github.com/Landrylab/FungAMR), please cite them as:

Bédard, C. et al. FungAMR: A comprehensive portrait of antimicrobial resistance mutations in fungi. bioRxiv, doi: [https://doi.org/10.1101/2024.10.07.617009](https://www.biorxiv.org/content/10.1101/2024.10.07.617009v2)

<br>

## 7. License<a name="id7"></a>

ChroQuetas and FungAMR are under Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International (**CC BY-NC-ND 4.0**) License

You are free to:

- Share — copy and redistribute the material in any medium or format for any purpose other than commercial purposes.

Under the following terms:

- Attribution — You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
- NonCommercial — You may not use the material for commercial purposes.
- NoDerivatives — If you remix, transform, or build upon the material, you may not distribute the modified material.
