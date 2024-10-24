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
5. [Expected output](#id5)
6. [Citation](#id5)

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

ChroQueTas only requires a fungal genome to work (to be specified with `-g/--genome`) and to enable few mandatory options, that include the path to the database (`-f/--fungamr`), the scheme that belongs to the species of the genome to be investigated (`-s/--scheme`) and the desired output directory name (`-o/--output`, ChroQueTas will create the output and will generate all the files there, as explained [here](#id5))   

```
OBLIGATORY OPTIONS:
    -f/--fungamr        Path to FungAMR database formatted for ChroQueTas
    -g/--genome         Path to the genome file
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

You can see an example of ChroQueTas usage in [this section](#id4)

<br>

## 3. Installation<a name="id3"></a>

> Right now, only installation **via source code** is available. A conda package and docker container are being prepared and will be released asap

ChroQueTas has been built and tested on Linux Debian, Ubuntu and Mint.   
\* *Incompatibilities might be encountered on MacOS systems, but we are working on them*

### 3.1 Via conda

```bash
conda install nmquijada::chroquetas
```

### 3.2 Via docker

The docker container can be build using

```shell
# Download repository
git clone https://github.com/nmquijada/ChroQueTas.git
docker build .
```

### 3.3 Via source code

```bash
# Install dependencies
conda install bioconda::blast bioconda::mafft miniprot

# Download repository
git clone https://github.com/nmquijada/ChroQueTas.git # while repo is private manual download is required
chmod 700 ChroQueTas/bin/ChroQueTas.sh
```

<br>

## 4. Example usage<a name="id4"></a>

Test ChroQueTas with different *Candida albicans* and *Zymoseptoria tritici* genomes included in the `test_dataset` directory.  
ChroQueTas has been built and tested on different Linux OS (Debian, Ubuntu and Mint) and hardware infraestructure (including laptop 16GB RAM, 8 CPUs; and servers 124GB RAM 20 CPUs, 1TB RAM 128 CPUs & 2TB RAM, 254 CPUs). **The running time per genome was a few seconds in all cases** (time is gold).

```bash
# From source code installation

## Candida albicans
/ChroQueTas/bin/ChroQueTas.sh -f ChroQueTas/db -g ChroQueTas/test_dataset/Calbicans_SRR13587609.fasta.gz -s Calbicans --min_id 75 --min_cov 75 -t 2 -o Calbicans_SRR13587609_ChroQueTas

## Zymoseptoria tritici
./ChroQueTas/bin/ChroQueTas.sh -f ChroQueTas/db -g ChroQueTas/test_dataset/Ztritici_SRR4907747.fasta.gz -s Ztritici --min_id 75 --min_cov 75 -t 2 -o Ztritici_SRR4907747_ChroQueTas 

# Some wildcards to automate the analysis in all genomes given in the test_dataset
for spp in Calbicans Ztritici; do
	for genome in $(ls ChroQueTas/test_dataset/${spp}*.fasta.gz | sed "s#.*/##" | sed "s/.fasta.gz//" | sed "s/${spp}_//"); do
		./ChroQueTas/bin/ChroQueTas.sh -g ChroQueTas/test_dataset/${spp}_${genome}.fasta.gz -o ${spp}_${genome}_ChroQueTas -f ChroQueTas/db -s ${spp} --min_id 75 --min_cov 75
	done
done
```

For the docker container, usage is similar (not available yet)

```bash
docker run <image name> -f db -g test_dataset/SRR7513134.fasta.gz -o test -s Ztritici
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
