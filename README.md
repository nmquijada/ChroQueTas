[![Anaconda-Server Badge](https://anaconda.org/nmquijada/chroquetas/badges/version.svg)](https://anaconda.org/nmquijada/chroquetas)
[![Anaconda-Server Badge](https://anaconda.org/nmquijada/chroquetas/badges/latest_release_date.svg)](https://anaconda.org/nmquijada/chroquetas)
[![Anaconda-Server Badge](https://anaconda.org/nmquijada/chroquetas/badges/license.svg)](https://anaconda.org/nmquijada/chroquetas)
[![Anaconda-Server Badge](https://anaconda.org/nmquijada/chroquetas/badges/downloads.svg)](https://anaconda.org/nmquijada/chroquetas)

<br>

# ChroQueTas

*<ins>Chro</ins>mosome <ins>Que</ins>ry <ins>Ta</ins>rget<ins>s</ins> </ins>*  

A user-friendly CLI software to perform antifungal/fungicide resistance screening in fungal genomes/proteomes  

<br>

## UPDATE! FungAMR and ChroQueTas paper is out! (2025-08-11)

Read the entire publication here:  

Bédard, C. et al. FungAMR: a comprehensive database for investigating fungal mutations associated
with antimicrobial resistance. *Nature Microbiology* (2025), https://doi.org/10.1038/s41564-025-02084-7

<br>

## Table of contents<a name="idindex"></a>
<img align="right" src="https://github.com/nmquijada/ChroQueTas/blob/images_files_wiki/CQTs_logo.png" width="20%">

1. [Introduction](#idintro)
2. [Instructions](#idinstr)
3. [Installation](#idinstall)
4. [Example usage](#idexample)
5. [Expected output](#idoutput)
6. [Limitations](#idlimit)
7. [Citation](#idcite)
8. [License](#idlicense)

<br>

## 1. Introduction<a name="idintro"></a>

**ChroQueTas** (*<ins>Chro</ins>mosome <ins>Que</ins>ry <ins>Ta</ins>rget<ins>s</ins> </ins>*) is a quick and user-friendly software that would allow you to identify **antimicrobial resistance in fungal genomes** in just a matter of seconds!  

You just need to provide a fungal genome, proteome (FASTA format) or annotation file (GBK, GBFF), either compressed or not, and to set some minimal options.  

ChroQueTas works in combination to the online database **[FungAMR](https://card.mcmaster.ca/fungamrhome)**, an outsanding resource for fungicide resistance. Entries consist of the gene, location of the mutation, and experimental data on drug susceptibility, with mutations classified using a [confidence score based on the degree of evidence](https://github.com/nmquijada/ChroQueTas/wiki/Confidence-score-for-antimicrobial-resistance) that supports their role in resistance.   
You can get further information of FungAMR from the [publication](https://doi.org/10.1038/s41564-025-02084-7), the [web site](https://card.mcmaster.ca/fungamrhome) and the [GitHub repository](https://github.com/Landrylab/FungAMR). FungAMR is automatically downloaded and formatted when installing ChroQueTas.  

> Not all the resistance mechanisms and species from FungAMR are available for ChroQueTas screening. Read more in the [limitations section](#idlimit)
 
<br>

With the information contained in [FungAMR](https://card.mcmaster.ca/fungamrhome), ChroQueTas will:   

- i) extract from the fungal genome the CDS and protein where a point mutation is known to cause AMR in that particular species by using miniprot (v.0.14-r265) and the information contained in FungAMR. The genetic code is automatically selected based on the `-s/--species` flag, but can be manually chosen by using `-c/--trans_code` (more info [here](https://raw.githubusercontent.com/nmquijada/ChroQueTas/refs/heads/v0.6.0/files/FungAMR_genetic_code.txt))  
- ii) evaluate sequence similarity against the reference by using BLASTP (v2.14.1+) and discard low confidence hits (default parameters are strict, but can be adjusted `--min_id`, `--min_cov` flags, although we recommend not being too flexible in order to prevent spurious alignments and misinterpretation of the results)
- iii) deal with potential introns, exons and InDels
- iv) multisequence alignment using MAFFT (v7.525) and evaluate amino acid positions between the query and the reference proteins accounting for FungAMR information
- v) report amino acid changes and InDels that could lead to AMR according to the confidence score in FungAMR (read more about the confidence score in the [wiki](https://github.com/nmquijada/ChroQueTas/wiki/Confidence-score-for-antimicrobial-resistance))

<br>

You can find a visual summary of the different steps conducted by ChroQueTas in this section of the [wiki](https://github.com/nmquijada/ChroQueTas/wiki/Step%E2%80%90by%E2%80%90step-tutorial).

<br> 

[Back to index](#idindex)

<br>

## 2. Instructions<a name="idinstr"></a>


> The instructions belong to v1.0.0. For older versions please check the [releases page](https://github.com/nmquijada/ChroQueTas/releases)


ChroQueTas only requires a fungal genome (FASTA file to be specified with `-g/--genome`. GBK and GBF annotation files are also allowed) or proteome (FASTA file to be specified with `-p/--proteome`) to work, the species of the genome to be investigated (`-s/--species`) and the desired output directory name (`-o/--output`), ChroQueTas will create the output and will generate all the files there, as explained [here](#idoutput)).   

You can list the species and proteins available by typing: `ChroQueTas.sh --list_species`  


```
OBLIGATORY OPTIONS:
    -g/--genome         Path to the genome file
    -o/--output         Path and name of the output directory
    -p/--proteome       Path to the proteome file
    -s/--species        Type the species you would like to conduct the analysis on
                        To inspect the pecies and proteins available use the '--list_species' flag

OTHER OPTIONS:
    -c/--trans_code     Specify number for Genetic Code to be used for protein translation, if needed (default= "12" for CTG clade and "1" for other fungi)
    --citation          Show citation
    -f/--fungamr        Path to FungAMR database formatted for ChroQueTas (default=installation path)
    --list_species      Provides the list of species and proteins that can be screened with ChroQueTas
    --min_cov           Sequence alignment coverage (percent) required for the target protein to be considered (default=75) <integer>
    --min_id            Sequence alignment similarity (percent) required for the target protein to be considered (default=90) <integer>
    -t/--threads        Number of threads to use (default=1) <integer>
    -v/--version        Show version
```

<br> 

> Please note: If a genetic code is not specified (`-c/--trans_code`), ChroQueTas will set this option automatically to the "alternative yeast code" (`-c 12`) for the species within the CTG clade or to the "standard code" (`-c 1`) for the other species. You can inspect the default behaviour [here](https://raw.githubusercontent.com/nmquijada/ChroQueTas/refs/heads/v0.6.0/files/FungAMR_genetic_code.txt).

<br>

You can see an example of ChroQueTas usage in [this section](#idexample)

<br>

[Back to index](#idindex)

<br>

## 3. Installation<a name="idinstall"></a>

ChroQueTas has been built and tested on Linux Debian, Ubuntu and Mint; under environments with python version 3.8 and 3.9.   

### 3.1 Via conda (recommended)

```bash
conda install -c nmquijada chroquetas=1.0
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

### 3.3 Via Docker

Usage via docker works as follows.

```
docker run --rm -it $IMAGE_NAME --list_species
```

<br> 

[Back to index](#idindex)

<br>

## 4. Example usage<a name="idexample"></a>

You can test ChroQueTas with different *Candida albicans* and *Zymoseptoria tritici* genomes included in the `test_dataset` directory.  

ChroQueTas has been built and tested on different Linux OS (Debian, Ubuntu and Mint) and hardware infraestructure (including laptop 16GB RAM, 8 CPUs; and servers 124GB RAM 20 CPUs, 1TB RAM 128 CPUs & 2TB RAM, 254 CPUs). **The running time per genome was a few seconds in all cases** (time is gold).  

<br>

```bash
## Candida albicans
ChroQueTas.sh -g test_dataset/Calbicans_SRR13587609.fasta.gz -s Candida_albicans -o Calbicans_SRR13587609_ChroQueTas
# Expected output: 2 AMR mutations: Cyp51 A114S and Y257H

## Zymoseptoria tritici
ChroQueTas.sh -g test_dataset/Ztritici_SRR4907747.fasta.gz -s Zymoseptoria_tritici -o Ztritici_SRR4907747_ChroQueTas 
# Expected output: 2 AMR mutations: Cyp51 L50S and Y461S
```

<br>

ChroQueTas can be run as simple as that... but of course some other options [can be added or modified](#idinstr), including the minimum percentage of identity (`--min_id`) or coverage (`--min_cov`) required for the "potential" query protein to be kept for downstream analysis.  
By default, we set strict parameters:  `--min_id = 90` and `--min_cov = 75`, with the rationale of achieving confident results values.  
This values can be modified by the user under certain circumstances, but please <ins>**be cautious**</ins>. Lowering the % coverage threshold might allow you to capture partial proteins resuling from a fragmented genome after assembly. However, lowering the % identity too much might allow to spurious misalignment to potential homologs/paralogs of the query protein that might be available in the genome and for what no AMR information is available, which could lead to misinterpretations of the results.   
Despite of this, we decided to keep this options open to the user to modify under certain circumstances/aims at **their own risk**, while we recommend caution when interpreting the results.

<br> 

[Back to index](#idindex)

<br>

## 5. Expected output<a name="idoutput"></a>

ChroQueTas will look in the genome for the different fungicide-target proteins available for the different species. For each of the proteins, ChroQueTas will generate:  

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

If your results file contain different "fragments" for the same protein, this `Fragments` value means the number of times that the protein was found in the genome/proteome. Having 2 fragments means that it was found in 2 different positions in your genome, either by potential duplications, aneuploidy or if the genome is too fragmented.   
In order to deepen in the possible reason for having more than one "fragement", the `.paf`, `.blastp.txt` and `tmp` files for the particular protein should be inspected.

You can find further information on **<ins>how to interpret the results</ins>** in this dedicated section of the [wiki](https://github.com/nmquijada/ChroQueTas/wiki/Confidence-score-for-antimicrobial-resistance).

<br> 

[Back to index](#idindex)

<br>

## 6. Limitations<a name="idlimit"></a>

It is **important to note** that, despite the many mechanisms for antifungal resistance (AFR) that FungAMR provides, the **current** version of ChroQueTas detects:
- Mutations causing AFR (other events including "gene duplication/loss", "disruption", "translocation", "aneuploidy", etc. are not considered <ins>**YET**</ins> ("*if there's a challenge to overcome, that means that we could still keep our jobs*"))
- Only **when** these mutations have been tested to cause resistance by their own (this is, alone and not in combination with other mutations).

This implies that from the 35,792 mutations from 95 species that FungAMR contains, ChroQueTas is currently including screening for 8,285 mutations and 57 species.  

The rationale behind this, is that at this point we would like to be robust with the AFR phenotype and thus report only those entries with a solid level of empyrical evidence.  
Additionally, we are missing an accurate reference protein for some species (which is an critical step, as a non-perfect reference might lead to spurious AFR profiling), which is the reason why some species are not included <ins>**YET**</ins> 

We are working hard to include as much mechanisms and species as possible and to keep ChroQueTas updated and ready to face the state-of-the-art.

<br> 

[Back to index](#idindex)

<br>

## 7. Citation<a name="idcite"></a>

When using ChroQueTas and/or FungAMR, please cite:

Bédard, C. et al. FungAMR: a comprehensive database for investigating fungal mutations associated
with antimicrobial resistance. *Nature Microbiology* (2025), https://doi.org/10.1038/s41564-025-02084-7

<br> 

[Back to index](#idindex)

<br>

## 8. License<a name="idlicense"></a>

ChroQuetas and FungAMR are under Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International (**CC BY-NC-ND 4.0**) License

You are free to:

- Share — copy and redistribute the material in any medium or format for any purpose other than commercial purposes.

Under the following terms:

- Attribution — You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
- NonCommercial — You may not use the material for commercial purposes.
- NoDerivatives — If you remix, transform, or build upon the material, you may not distribute the modified material.
