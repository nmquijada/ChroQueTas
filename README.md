# ChroQueTas

<img align="right" src="https://github.com/nmquijada/ChroQueTas/blob/images/temprorary_CQTs_logo_AJA.jpeg" width="20%">

*<ins>Chro</ins>mosome <ins>Que</ins>ry <ins>Ta</ins>rget<ins>s</ins> </ins>*  

\* *Repository under development*

<br>

## IMPORTANT UPDATE (10 Dec 2024)
**We are transitioning to ChroQueTas v0.5.0!**  

This release will contain:
- The schemes for **all** the species contained in FungAMR, as described in the [preprint](https://www.biorxiv.org/content/10.1101/2024.10.07.617009v1).
- The level of evidence for each mutation according to the [FungAMR database](https://github.com/Landrylab/FungAMR).
- A package available for its installation via conda.  

We will finish the transition in the following days. Thank you for your patience.

<br>

## Table of contents
1. [Introduction](#id1)
2. [Instructions](#id2)
3. [Installation](#id3)
4. [Example usage](#id4)
5. [Expected output](#id5)
6. [Citation](#id6)
7. [License](#id7)

<br>

## 1. Introduction<a name="id1"></a>

ChroQueTas (*<ins>Chro</ins>mosome <ins>Que</ins>ry <ins>Ta</ins>rget<ins>s</ins> </ins>*) is a quick and user-friendly software that would allow you to dientify **antimicrobial resistance in fungal genomes** in just a matter of seconds! You just need to provide a fungal genome (in FASTA format, can be gz-compressed) and to set some minimal options.

ChroQueTas works in combination to [FungAMR](https://github.com/Landrylab/FungAMR), an outsanding resource for antimicrobial resistance (AMR), that contains 54,666 mutation entries (all classified with the degree of evidence that supports their role in resistance), covering 92 species, 202 genes and 184 fungicides. FungAMR and ChroQueTas have been submitted for publication, where you could read the [preprint](https://www.biorxiv.org/content/10.1101/2024.10.07.617009v1). You can download the whole FungAMR resource from [it's main GitHub repository](https://github.com/Landrylab/FungAMR) and also the formatted one when downloading and installing ChroQueTas.  

With that information contained in [FungAMR](https://github.com/Landrylab/FungAMR), ChroQueTas will:   

- i) extract from the fungal genome the CDS and protein where a point mutation is known to cause AMR in that particular species by using miniprot (v0.12-r23750) and the information contained in FungAMR.  
- ii) evaluate sequence similarity against the reference by using BLASTP (v2.14.1+) and discard low confidence hits (to be specified by the user and the `--min_id`, `--min_cov` flags)
- iii) deal with potential introns, exons and InDels
- iv) evaluate amino acid positions between the query and the reference proteins accounting for FungAMR information
- v) report amino acid changes and InDels that could lead to AMR according to the confidence score in FungAMR

<br> 

## 2. Instructions<a name="id2"></a>

> Instructions belonging to v0.5.0. For older versions please check the [releases page](https://github.com/nmquijada/ChroQueTas/releases)


ChroQueTas only requires a fungal genome to work (to be specified with `-g/--genome`), the scheme that belongs to the species of the genome to be investigated (`-s/--scheme`) and the desired output directory name (`-o/--output`, ChroQueTas will create the output and will generate all the files there, as explained [here](#id5)).   

You can list the schemes available by typing: `ChroQueTas.sh --list_schemes`  

```
OBLIGATORY OPTIONS:
    -g/--genome         Path to the genome file
    -o/--output         Path and name of the output directory
    -s/--scheme         Type the scheme you would like to conduct the analysis on
                        To inspect the schemes available use the '--list_schemes' flag

OTHER OPTIONS:
    -f/--fungamr        Path to FungAMR database formatted for ChroQueTas
    --list_schemes      Provides the description of species (schemes) that can be screened with ChroQueTas
    --min_cov           Sequence alignment coverage (percent) required for the target protein to be considered (default=75) <integer>
    --min_id            Sequence alignment similarity (percent) required for the target protein to be considered (default=75) <integer>
    -t/--threads        Number of threads to use (default=1) <integer>
    -v/--version        Show version
```

<br> 

You can see an example of ChroQueTas usage in [this section](#id4)

<br>

## 3. Installation<a name="id3"></a>

ChroQueTas has been built and tested on Linux Debian, Ubuntu and Mint; under environments with python version 3.8 and 3.9.   
\* *Incompatibilities might be encountered on MacOS systems, but we are working on them*

### 3.1 Via conda (recommended)

```bash
conda install -c nmquijada chroquetas
```

### 3.2 Via source code

```bash
# Install dependencies
conda install bioconda::blast bioconda::mafft miniprot

# Download repository
git clone https://github.com/nmquijada/ChroQueTas.git # while repo is private manual download is required
chmod 700 ChroQueTas/bin/ChroQueTas.sh
unzip ChroQueTas/FungAMR_db.zip
# Clean the house (optional)
rm -r ChroQueTas/FungAMR_db.zip
```

<br>

## 4. Example usage<a name="id4"></a>

Test ChroQueTas with different *Candida albicans* and *Zymoseptoria tritici* genomes included in the `test_dataset` directory.  
ChroQueTas has been built and tested on different Linux OS (Debian, Ubuntu and Mint) and hardware infraestructure (including laptop 16GB RAM, 8 CPUs; and servers 124GB RAM 20 CPUs, 1TB RAM 128 CPUs & 2TB RAM, 254 CPUs). **The running time per genome was a few seconds in all cases** (time is gold).

```bash
## Candida albicans
ChroQueTas.sh -g test_dataset/Calbicans_SRR13587609.fasta.gz -s Candida_albicans --min_id 75 --min_cov 75 -t 2 -o Calbicans_SRR13587609_ChroQueTas

## Zymoseptoria tritici
ChroQueTas.sh -g test_dataset/Ztritici_SRR4907747.fasta.gz -s Zymoseptoria_tritici --min_id 75 --min_cov 75 -t 2 -o Ztritici_SRR4907747_ChroQueTas 
```

<br>

## 5. Expected output<a name="id5"></a>

ChroQueTas will look in the genome for the different fungicide-target proteins available for the different schemes (see [here](https://github.com/nmquijada/ChroQueTas/tree/main/db)). For each of the proteins, ChroQueTas will generate:  
- **Results file** (`name.ChroQueTas.protein.tsv`): a tabular file were every single amino acid position included in [FungAMR](https://github.com/Landrylab/FungAMR) is reported together with the amino acid occurring in both the reference and the query genomes. The field `Results` could report the following:
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

Bédard, C. et al. FungAMR: A comprehensive portrait of antimicrobial resistance mutations in fungi. bioRxiv, doi: [https://doi.org/10.1101/2024.10.07.617009](https://www.biorxiv.org/content/10.1101/2024.10.07.617009v1)

<br>

## 7. License<a name="id6"></a>

ChroQuetas and FungAMR are under Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International (**CC BY-NC-ND 4.0**) License

You are free to:

- Share — copy and redistribute the material in any medium or format for any purpose other than commercial purposes.

Under the following terms:

- Attribution — You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
- NonCommercial — You may not use the material for commercial purposes.
- NoDerivatives — If you remix, transform, or build upon the material, you may not distribute the modified material.

