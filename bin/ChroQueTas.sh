#! /bin/bash

##############
# ChroQueTaS #
##############

AUTHORS="Narciso M. Quijada, Alejandro J. Alcañiz, David Mendoza-Salido, Sibbe Bakker"
VERSION="1.0.0"
LASTMODIF="2025-08-11"

ChroQueTas=$0
while [ -h "$ChroQueTas" ]; do # resolve $ChroQueTas until the file is no longer a symlink
  ChroQueTasDIR="$( cd -P "$( dirname "$0" )" && pwd )"
  ChroQueTas="$(readlink "$ChroQueTas")"
  [[ $ChroQueTas != /* ]] && ChroQueTas="$ChroQueTasDIR/$ChroQueTas" # if $ChroQueTas is a symlink, resolve it relative to the path where the symlink file was located
done
ChroQueTasDIR="$( cd -P "$( dirname "$ChroQueTas" )" && pwd )"

# WORKNING VARIABLES
FungAMR=${ChroQueTasDIR}/../FungAMR_db
INDIR=
INGENOME=
INGENOME_PATH=
INGENOME_SUFFIX=
INPROT_PATH=
INPUT_FORMAT=
MINID=90
MINCOV=75
NCPUS=1
OUTPUT=
QUERYPROT=
SPECIES=
TRANSCODE=

# Message colors
COL_RESET=$(tput sgr 0)
COL_blue=$(tput setaf 4)
COL_cyan=$(tput setaf 6)
COL_green=$(tput setaf 2)
COL_magenta=$(tput setaf 5)
COL_purple=$(tput setaf 5)
COL_red=$(tput setaf 1)
COL_white=$(tput setaf 7)
COL_yellow=$(tput setaf 3)

# FUNCTIONS
get_aa_from_pos () {
    grep -A 1 -P "^>${2}" ${1} | grep -vP "^>${2}" | awk "{ print substr( \$0, $3, 1 ) }"
}
get_dash_pos () {
    grep -A 1 -P "^>${2}" ${1} | grep -vP "^>${2}" | grep -ob "-" | sed "s/:-$//"
}
get_input_format () {
    seqkit stats ${1} 2>>/dev/null | tail -n+2 | sed -E 's/[[:space:]]+/\t/g' | cut -f 3
}
multi2single_line_fasta () {
    cat $1 | awk '/^>/ {printf("\n%s\n",$0);next; } { printf("%s",$0);}  END {printf("\n");}' | sed "/^$/d"
}


usage () {

echo -e "${COL_yellow}   ____ _                ___            _____          "
echo -e "  / ___| |__  _ __ ___  / _ \ _   _  __|_   _|_ _ ___  "
echo -e " | |   | '_ \| '__/ _ \| | | | | | |/ _ \| |/ _\` / __| "
echo -e " | |___| | | | | | (_) | |_| | |_| |  __/| | (_| \__ \ "
echo -e "  \____|_| |_|_|  \___/ \__\__\\__,_|\___||_|\__,_|___/   ${COL_RESET}v${VERSION}"

cat << EOF


This is ChroQueTas version ${VERSION}
Last modification: ${LASTMODIF}
Developed by: ${AUTHORS}

usage: $0 <-g genome//-p proteome> <-s species> <-o output> <other options>

${COL_green}OBLIGATORY OPTIONS:${COL_RESET}
    -g/--genome         Path to the genome file
    -o/--output         Path and name of the output directory
    -p/--proteome       Path to the proteome file
    -s/--species        Type the species you would like to conduct the analysis on
                        To inspect the pecies and proteins available use the '--list_species' flag

${COL_cyan}OTHER OPTIONS:${COL_RESET}
    -c/--trans_code     Specify number for alternative Genetic Code, if needed (default= "12" for CTG clade and "1" for other fungi)
    --citation          Show citation
    -f/--fungamr        Path to FungAMR database formatted for ChroQueTas (default=$(realpath ${ChroQueTasDIR}/../FungAMR_db))
    --list_species      Provides the list of species and proteins that can be screened with ChroQueTas
    --min_cov           Sequence alignment coverage (percent) required for the target protein to be considered (default=$MINCOV) <integer>
    --min_id            Sequence alignment similarity (percent) required for the target protein to be considered (default=$MINID) <integer>
    -t/--threads        Number of threads to use (default=$NCPUS) <integer>
    -v/--version        Show version


For further details, please visit: https://github.com/nmquijada/ChroQueTas
EOF
}

if [ $# == 0 ]; then
	usage
	exit 1
fi

# VARIABLE OPTIONS

POSITIONAL=()
while [[ $# -gt 0 ]]
do
ARGS="$1"

case $ARGS in
    -c|--trans_code)
    if [ "$2" ]; then
      if [ "$2" -eq "$2"  ] 2>/dev/null ; then
        TRANSCODE=$2
        shift 2
      else
        echo -e "\n${COL_red}ERROR: '-c/--trans_code' requires a numeric argument [1-33]${COL_RESET}\nargument parsed: $2 \nPlease take a look at https://www.ncbi.nlm.nih.gov/Taxonomy/Utils/wprintgc.cgi\n"
        exit 1
      fi
    else
      echo -e "\n${COL_red}ERROR: '-c/--trans_code' requires a numeric argument${COL_RESET}\nPlease take a look at https://www.ncbi.nlm.nih.gov/Taxonomy/Utils/wprintgc.cgi\n"
      exit 1
    fi
    ;;
    --citation)
    echo -e "\nWhen using ChroQueTas please cite:\n\nBédard, C. et al. FungAMR: a comprehensive database for investigating fungal mutations associated with antimicrobial resistance.\nNature Microbiology (2025), https://doi.org/10.1038/s41564-025-02084-7\n"
    exit 1
    ;;
    -f|--fungamr)
    if [ "$2" ]; then
        FungAMR=$2
        shift 2
        if [ ! -d "${FungAMR}" ]; then
            echo -e "\n${COL_red}ERROR: ${FungAMR} doesn't exist!${COL_RESET} Please check \n"
            exit 1
        fi
        if [ ! "$(ls -A ${FungAMR})" ]; then
            echo -e "\n${COL_red}ERROR: ${FungAMR} is empty!${COL_RESET} Please check \n"
            exit 1
        fi
    else
        echo -e '\nERROR: "-f/--fungamr" requires an argument\n'
        exit 1
    fi
    ;;
    -g|--genome)
    if [ "$2" ]; then
        INGENOME_PATH=$2
        shift 2
        if [ ! -s "${INGENOME_PATH}" ]; then
            echo -e "\n${COL_red}ERROR: ${INGENOME_PATH} doesn't exist or is empty!${COL_RESET} Please check \n"
            exit 1
        fi
    else
        echo -e "\n${COL_red}ERROR: '-g/--genome' requires an argument${COL_RESET}\n"
        exit 1
    fi
    ;;
    -o|--output)
    if [ "$2" ]; then
        OUTPUT=$2
        shift 2
        if [ -d "${OUTPUT}" ]; then
            echo -e "\n${COL_red}ERROR: ${OUTPUT} already exist! Please check${COL_RESET}\n"
            exit 1
        fi
    else
        echo -e "\n${COL_red}ERROR: '-o/--output' requires an argument${COL_RESET}\n"
        exit 1
    fi
    ;;
    --list_species)
    if [ ! -d "$FungAMR" ]; then
        echo -e "\n${COL_red}ERROR: '-f/--fungamr' database not found!${COL_RESET}\n"
        exit 1
    else
        echo -e "Species\tProteins_to_screen"
        for species in $(ls ${FungAMR}); do
            echo -e "${species}\t$(ls ${FungAMR}/${species} | grep "faa" | sed "s/.faa//" | tr '\n' ',' | sed "s/,$/\n/")"
        done
        exit 1
    fi
    ;;
    --min_cov)
    if [ "$2" ]; then
      if [ "$2" -eq "$2"  ] 2>/dev/null ; then
        MINCOV=$2
        shift 2
      else
        echo -e "\n${COL_red}ERROR: '--min_cov' requires a numeric argument${COL_RESET}\nargument parsed: $2 \n"
        exit 1
      fi
    else
      echo -e "\n${COL_red}ERROR: '--min_cov' requires a numeric argument${COL_RESET}\n"
      exit 1
    fi
    ;;
    --min_id)
    if [ "$2" ]; then
      if [ "$2" -eq "$2"  ] 2>/dev/null ; then
        MINID=$2
        shift 2
      else
        echo -e "\n${COL_red}ERROR: '--min_id' requires a numeric argument${COL_RESET}\nargument parsed: $2 \n"
        exit 1
      fi
    else
      echo -e "\n${COL_red}ERROR: '--min_id' requires a numeric argument${COL_RESET}\n"
      exit 1
    fi
    ;;
    -p|--proteome)
    if [ "$2" ]; then
        INPROT_PATH=$2
        shift 2
        if [ ! -s "${INPROT_PATH}" ]; then
            echo -e "\nERROR: ${INPROT_PATH} doesn't exist or is empty! Please check \n"
            exit 1
        fi
    else
        echo -e '\nERROR: "-p/--proteome" requires an argument\n'
        exit 1
    fi
    ;;
    -s|--species)
    if [ "$2" ]; then
        if grep -q "${2}" <(ls ${FungAMR}); then
            SPECIES=$2
            shift 2
        else
            echo -e "\n${COL_red}ERROR: unknown option for '-s/--species'${COL_RESET}"
			echo -e "Argument parsed: $2 \nTo inspect the species available use the '--list_species' flag \n"
		    exit 1
	    fi
    else
        echo -e "\n${COL_red}ERROR: '-s/--species' requires an argument${COL_RESET}"
        echo "To inspect the species available use the '--list_species' flag \n"
        exit 1
    fi
    ;;
    -t|--threads)
	if [ "$2" ]; then
		if [ "$2" -eq "$2"  ] 2>/dev/null ; then
            NCPUS=$2
            shift 2
        else
            echo -e '\nERROR: "-t/--threads" requires a numeric argument'
            echo -e "argument parsed: $2 \n"
            exit 1
        fi
	else
		echo -e '\nERROR: "-t/--threads" requires a numeric argument\n'
        exit 1
    fi
	;;
    -v|--version)
        echo "${COL_yellow}ChroQueTas (Chromosome Query Targets) version ${VERSION}${COL_RESET}"
        exit 1
    ;;
    -?*)
	    usage
        echo -e "\n${COL_red}ERROR: unknown option: ${1}${COL_RESET}\n"
	    exit 1
	;;
	*)
	    usage
        echo -e "\n${COL_red}ERROR: unknown option: ${1}${COL_RESET}\n"
        exit 1
    ;;
esac
done
set -- "${POSITIONAL[@]}" #restore positional parameters


# CHECK REDUNDANT OPTIONS
if [[ "$INPROT_PATH" && "$INGENOME_PATH" ]]; then
	echo -e "\n${COL_red}ERROR: '-g/--genome' and '-p/--proteome' options cannot be used simultaneously!${COL_RESET}\n"
	exit 1
fi

# CHECK MANDATORY VARIABLES
if [ -z "$FungAMR" ]; then
    usage
    echo -e "\n${COL_red}ERROR: '-f/--fungamr' option is needed!${COL_RESET}\n"
    exit 1
fi
if [[ "$INPROT_PATH" ]]; then
    INGENOME_PATH=$INPROT_PATH
    INPUT_FORMAT="prot"
else
    INPUT_FORMAT="nucl"
fi
if [ -z "$INGENOME_PATH" ]; then
    usage
    echo -e "\n${COL_red}ERROR: either '-g/--genome' or '-p/--proteome' options are needed!${COL_RESET}\n"
    exit 1
fi
if [ -z "$OUTPUT" ]; then
    usage
    echo -e "\n${COL_red}ERROR: '-o/--output' option is needed!${COL_RESET}\n"
    exit 1
fi
if [ -z "$SPECIES" ]; then
    usage
    echo -e "\n${COL_red}ERROR: '-s/--species' option is needed!${COL_RESET}\n"
    exit 1
fi

## Define TRANSCODE if not specified
if [ -z "$TRANSCODE" ]; then
    CTGCLADE=("Candida_albicans" "Candida_dubliniensis" "Candida_metapsilosis" "Candida_orthopsilosis" "Candida_parapsilosis" "Candida_tropicalis" "Candidozyma_auris" "Clavispora_lusitaniae")
    isCTG=false
    for CTGspp in "${CTGCLADE[@]}"; do
        if [[ "$SPECIES" == "$CTGspp" ]]; then
            isCTG=true
            break
        fi
    done
    if $isCTG; then
        trans_code_message=$(echo -e "PLEASE NOTE: as -c/--trans_code has not been specified and $SPECIES belongs to CTG clade, genetic code has been automatically set to "alternative yeast code" (12)")
        TRANSCODE=12
    else
        trans_code_message=$(echo -e "PLEASE NOTE: as -c/--trans_code has not been specified the genetic code has been automatically set to "standard genetic code" (1)")
        TRANSCODE=1
    fi
fi

# Check if all mandatory software are installed
for mysoft in miniprot blastp mafft seqret seqkit; do
    if ! command -v $mysoft &>/dev/null; then
        echo -e "\n${COL_red}ERROR: ${mysoft} is required and not installed${COL_RESET}\nPlease check the installation instructions in: https://github.com/nmquijada/ChroQueTas"
        exit 1
    fi
done

# Set Working Directory
mkdir -p $OUTPUT
if [ ! -d $OUTPUT ]; then
	echo -e "\n${COL_red}ERROR: $OUTPUT could not be created in the selected location.${COL_RESET}\nPlease check\n"
	exit 1
fi
#OUTEMP="$( cd -P "$( dirname "$OUTPUT" )" && pwd )"
#OUTWD="$OUTEMP/$OUTPUT"
OUTWD=$(realpath $OUTPUT)

# Define genome/file name and extension
INGENOME_PATH_BASE=$(basename $INGENOME_PATH)
INGENOME_SUFFIX="${INGENOME_PATH_BASE##*.}" # miniprot works with gz but not with bz2 files
#INGENOME_SUFFIX="${INGENOME_PATH_BASE#*.}" # fasta.gz
if [[ "$INGENOME_SUFFIX"  == 'bz2' ]]; then
    echo -e "${COL_purple}INFO: ${INGENOME_PATH} is bzipped. Only gzip compressions are allowed. Converting bz2 to gz... !${COL_RESET}\n"
    bunzip2 -c "$INGENOME_PATH" | gzip > "${INGENOME_PATH%.bz2}.gz"
    if [[ $? -ne 0 ]]; then
        echo -e "${COL_red}ERROR:Failed to convert .bz2 to .gz${COL_RESET} "
        exit 1
    fi
    INGENOME_PATH="${INGENOME_PATH%.bz2}.gz"
    INGENOME_SUFFIX="gz"
fi
if [[ "$INGENOME_SUFFIX"  == 'gz' ]]; then
    INGENOME="${INGENOME_PATH_BASE%%.*}"
else
    INGENOME="${INGENOME_PATH_BASE%.*}"
fi

# CHECK IF THERE ARE PERMISSIONS TO WRITE IN OUTDIR
mkdir ${OUTWD}/tmp/
if [ ! -d "${OUTWD}/tmp/" ]; then
    echo -e "\n${COL_red}ERROR: $OUTPUT could not be created in the selected location.${COL_RESET}\nPlease check\n"
    exit 1
fi

# VALIDATE INPUT FORMAT
if [[ "$INPUT_FORMAT" == "prot" ]]; then
    temp_format="$(get_input_format ${INGENOME_PATH})"
    if [[ "$temp_format" == "DNA" ]]; then
            echo -e "\n${COL_red}ERROR: Input file looks like a genome file...${COL_RESET}\nPlease use -g/--genome option instead\n"
            exit 1
        fi
    if [[ "$temp_format" != "Protein" ]]; then
        echo -e "\n${COL_red}ERROR: Input file does not look as a protein FASTA file...${COL_RESET}\nPlease check\n"
        exit 1
    fi
    # Blastp does not work with gz or bz2 fasta
    if [[ "$INGENOME_SUFFIX"  == 'bz2' ]]; then
        bzcat ${INGENOME_PATH} > ${OUTWD}/tmp/${INGENOME}.faa
        INGENOME_PATH=${OUTWD}/tmp/${INGENOME}.faa
    fi
    if [[ "$INGENOME_SUFFIX"  == 'gz' ]]; then
        zcat ${INGENOME_PATH} > ${OUTWD}/tmp/${INGENOME}.faa
        INGENOME_PATH=${OUTWD}/tmp/${INGENOME}.faa
    fi
fi
if [[ "$INPUT_FORMAT" == "nucl" ]]; then
    temp_format="$(get_input_format ${INGENOME_PATH})"
    if [[ "$temp_format" != "DNA" ]]; then
        if [[ "$temp_format" == "Protein" ]]; then
            echo -e "\n${COL_red}ERROR: Input file looks like a protein FASTA file...${COL_RESET}\nPlease use -p/--proteome option instead\n"
            exit 1
        fi
        # Let's assume it's an annotation file then... force conversion to nucl FASTA!
        if [[ "$INGENOME_SUFFIX"  == 'gz' ]]; then
            zcat ${INGENOME_PATH} > ${OUTWD}/tmp/${INGENOME}.tmp
            seqret -auto -sequence ${OUTWD}/tmp/${INGENOME}.tmp -osformat2 fasta -outseq ${OUTWD}/tmp/${INGENOME}.fasta
            rm ${OUTWD}/tmp/${INGENOME}.tmp
        else
            seqret -auto -sequence ${INGENOME_PATH} -osformat2 fasta -outseq ${OUTWD}/tmp/${INGENOME}.fasta
        fi
        temp_format="$(get_input_format ${OUTWD}/tmp/${INGENOME}.fasta)"
        if [[ "$temp_format" != "DNA" ]] && [[ "$temp_format" != "Protein" ]]; then
            echo -e "\n${COL_red}ERROR: Input file does not look as a FASTA or annotation file...${COL_RESET}\nPlease check\n"
            exit 1
        else
            INGENOME_PATH=${OUTWD}/tmp/${INGENOME}.fasta
        fi
    fi
fi

# START WORKING... Put ChroQueTas in your life!

echo -e "\nPut some...\n"
echo -e "${COL_yellow}   ____ _                ___            _____          "
echo -e "  / ___| |__  _ __ ___  / _ \ _   _  __|_   _|_ _ ___  "
echo -e " | |   | '_ \| '__/ _ \| | | | | | |/ _ \| |/ _\` / __| "
echo -e " | |___| | | | | | (_) | |_| | |_| |  __/| | (_| \__ \ "
echo -e "  \____|_| |_|_|  \___/ \__\__\\__,_|\___||_|\__,_|___/   ${COL_RESET}v${VERSION}"
echo -e "\n\n                                                            ...IN YOUR LIFE!"
echo -e "\nFour steps and you are there!"

# Define Query protein and loop
QUERYNUM=$(ls ${FungAMR}/${SPECIES}/*faa | wc -l)
echo -e "\nThe species ${SPECIES} has ${QUERYNUM} proteins associated with AMR\n"
if [[ ! -z $trans_code_message ]]; then
    echo -e "${trans_code_message}\n"
fi
if [[ "$MINID" < 90 ]]; then
    echo -e "${COL_yellow}WARNING: the %identity threshold for protein alignment has been set below the default (value chosen=${MINID}%)\nPlease, be when careful interpreting the results${COL_RESET}\n"
fi

for QUERYPROT_PATH in $(ls ${FungAMR}/${SPECIES}/*faa); do
    QUERYPROT=$(basename ${QUERYPROT_PATH} .faa)
    echo ${QUERYPROT} >> ${OUTWD}/tmp/queries_list.tmp
done

# 1. Protein prediction and extraction
if [[ "$INPUT_FORMAT" == "nucl" ]]; then
    echo -e "${COL_yellow}Running protein prediction and extraction (step 1/4)${COL_RESET}"
    # 1.1. Reference genome for miniprot
    miniprot -T ${TRANSCODE} -G 5000 -t ${NCPUS} -d ${OUTWD}/tmp/${INGENOME}.mpi ${INGENOME_PATH} 2>/dev/null
    for QUERYPROT in $(<${OUTWD}/tmp/queries_list.tmp); do
        prot_query_name="${INGENOME}_${QUERYPROT}"
        miniprot -T ${TRANSCODE} -G 5000 -t ${NCPUS} ${OUTWD}/tmp/${INGENOME}.mpi ${FungAMR}/${SPECIES}/${QUERYPROT}.faa --trans > ${OUTWD}/tmp/${prot_query_name}.tmp 2>/dev/null
        num_features=$(grep -c "^\#\#STA" ${OUTWD}/tmp/${prot_query_name}.tmp)
        counter=1
        cp ${OUTWD}/tmp/${prot_query_name}.tmp ${OUTWD}/tmp/${prot_query_name}.miniprot.tmp
        until [ $counter -gt $num_features ]; do
            head -n 1 ${OUTWD}/tmp/${prot_query_name}.tmp > ${OUTWD}/${prot_query_name}.${counter}.paf
            tail -n+2 ${OUTWD}/tmp/${prot_query_name}.tmp | head -n 1 | grep "^\#\#STA" | tr '\t' '\n' | sed "s/^##STA/>${prot_query_name}.${counter}/" > ${OUTWD}/${prot_query_name}.${counter}.faa
            tail -n+3 ${OUTWD}/tmp/${prot_query_name}.tmp > ${OUTWD}/tmp/file2remove.tmp
            mv ${OUTWD}/tmp/file2remove.tmp ${OUTWD}/tmp/${prot_query_name}.tmp
            let counter++
        done
        rm ${OUTWD}/tmp/${prot_query_name}.tmp
        ## --> Check if any paf or faa files were created
        if [ ! -s "${OUTWD}/${prot_query_name}.1.faa" ] || [ ! -s "${OUTWD}/${prot_query_name}.1.paf" ]; then
            echo -e "${COL_yellow}WARNING: We could not extract ${QUERYPROT} from the genome...\nProtein will be discarded for further screening${COL_RESET}"
            sed -i "s/${QUERYPROT}//" ${OUTWD}/tmp/queries_list.tmp; sed -i "/^$/d" ${OUTWD}/tmp/queries_list.tmp
            #rm ${OUTWD}/${prot_query_name}.1.faa ${OUTWD}/${prot_query_name}.1.paf
        fi
    done
    if [  "$(ls ${OUTWD}/*.faa 2>/dev/null | wc -l )" -gt 0 ] ; then
        echo -e "${COL_green}Done! (step 1/4)${COL_RESET}"
    else
        echo -e "\n${COL_yellow}WARNING: ChroQuetas could not extract any query proteins from the genome...\nExiting...${COL_RESET}\nStill... Thanks for using ChroQueTas!\n"
        exit 1
    fi
fi
if [[ "$INPUT_FORMAT" == "prot" ]]; then
    echo -e "${COL_green}Protein prediction and extraction step not needed... Done! (step 1/4)${COL_RESET}"
fi

# 2. Run blast and report stats
echo -e "${COL_yellow}Calculating protein similarity with reference (step 2/4)${COL_RESET}"
if [[ "$INPUT_FORMAT" == "nucl" ]]; then
    for QUERYPROT in $(<${OUTWD}/tmp/queries_list.tmp); do
        prot_query_name="${INGENOME}_${QUERYPROT}"
        #num_features=$(ls ${OUTWD}/${prot_query_name}.+([0-9]).faa | wc -l)
        num_features=$(ls ${OUTWD}/${prot_query_name}.*.faa | wc -l)
        counter=1
        until [ $counter -gt $num_features ]; do
            blastp -query ${OUTWD}/${prot_query_name}.${counter}.faa -subject ${FungAMR}/${SPECIES}/${QUERYPROT}.faa -out ${OUTWD}/tmp/${prot_query_name}.${counter}.blastp.tmp -evalue 1E-10 -outfmt "6 qseqid sseqid qlen slen pident length gaps evalue bitscore qstart qend sstart send"
            cat ${OUTWD}/tmp/${prot_query_name}.${counter}.blastp.tmp | awk -v OFS="\t" -F "\t" '{print $0, $14=($6-$7)*100/$4}' | awk -v OFS="\t" -v MINID=${MINID} -F "\t" '($5 > MINID)' | awk -v OFS="\t" -v MINCOV=${MINCOV} -F "\t" '($14 > MINCOV)' | sed "1iQuery\tReference\tquery_length\tsubject_length\tperc_identity\tlength_alignment\tgaps\tevalue\tbitscore\tqstart\tqend\tsstart\tsend\tperc_coverage" | awk -v OFS="\t" -F "\t" '{print $1,$2,$5,$14,$8,$3,$4,$6,$7,$9,$10,$11,$12,$13}' > ${OUTWD}/${prot_query_name}.${counter}.blastp.txt
            if [[ $(cat ${OUTWD}/${prot_query_name}.${counter}.blastp.txt | wc -l) -lt 2 ]]; then
                rm ${OUTWD}/${prot_query_name}.${counter}.blastp.txt
            fi
            let counter++
        done
    done
fi
if [[ "$INPUT_FORMAT" == "prot" ]]; then
    for QUERYPROT in $(<${OUTWD}/tmp/queries_list.tmp); do
        prot_query_name="${INGENOME}_${QUERYPROT}"
        blastp -query ${INGENOME_PATH} -subject ${FungAMR}/${SPECIES}/${QUERYPROT}.faa -evalue 1E-10 -outfmt "6 qseqid sseqid qlen slen pident length gaps evalue bitscore qstart qend sstart send" | awk -v OFS="\t" -F "\t" '{print $0, $14=($6-$7)*100/$4}' | awk -v OFS="\t" -v MINID=${MINID} -F "\t" '($5 > MINID)' | awk -v OFS="\t" -v MINCOV=${MINCOV} -F "\t" '($14 > MINCOV)' | sed "1iQuery\tReference\tquery_length\tsubject_length\tperc_identity\tlength_alignment\tgaps\tevalue\tbitscore\tqstart\tqend\tsstart\tsend\tperc_coverage" | awk -v OFS="\t" -F "\t" '{print $1,$2,$5,$14,$8,$3,$4,$6,$7,$9,$10,$11,$12,$13}' > ${OUTWD}/tmp/${prot_query_name}.blastp.txt
        # Extract individual proteins that gave a hit from the proteome
        if [[ $(cat ${OUTWD}/tmp/${prot_query_name}.blastp.txt | wc -l) -gt 1 ]]; then
            num_features=$(cut -f 1 ${OUTWD}/tmp/${prot_query_name}.blastp.txt | tail -n+2 | wc -l)
            counter=1
            until [ $counter -gt $num_features ]; do
                matching_protein=$(cut -f 1 ${OUTWD}/tmp/${prot_query_name}.blastp.txt | tail -n+2 | sed -n "${counter}p")
                seqkit grep -p "${matching_protein}" "${INGENOME_PATH}" > "${OUTWD}/${prot_query_name}.${counter}.faa"
                grep -w "${matching_protein}" ${OUTWD}/tmp/${prot_query_name}.blastp.txt | sed "1i$(head -n 1 ${OUTWD}/tmp/${prot_query_name}.blastp.txt)" > ${OUTWD}/${prot_query_name}.${counter}.blastp.txt
                if [[ $(cat ${OUTWD}/${prot_query_name}.${counter}.blastp.txt | wc -l) -lt 2 ]]; then
                    rm ${OUTWD}/${prot_query_name}.${counter}.blastp.txt
                fi
                let counter++
            done
        else
            echo -e "${COL_yellow}WARNING: We could not extract ${QUERYPROT} from the genome...\nProtein will be discarded for further screening${COL_RESET}"
            sed -i "s/${QUERYPROT}//" ${OUTWD}/tmp/queries_list.tmp; sed -i "/^$/d" ${OUTWD}/tmp/queries_list.tmp
        fi
    done
    if [  "$(ls ${OUTWD}/*.faa 2>/dev/null | wc -l )" == 0 ] ; then
        echo -e "\n${COL_yellow}WARNING: ChroQuetas could not extract any query proteins from the proteome...\nExiting...${COL_RESET}\nStill... Thanks for using ChroQueTas!\n"
        exit 1
    fi
fi
echo -e "${COL_green}Done! (step 2/4)${COL_RESET}"

# 3. MAFFT alignment
echo -e "${COL_yellow}Performing alignment with reference (step 3/4)${COL_RESET}"
for QUERYPROT in $(<${OUTWD}/tmp/queries_list.tmp); do
    prot_query_name="${INGENOME}_${QUERYPROT}"
    num_features=$(ls ${OUTWD}/${prot_query_name}.*.faa | wc -l)
    counter=1
    until [ $counter -gt $num_features ]; do
        if [ -s "${OUTWD}/${prot_query_name}.${counter}.blastp.txt" ]; then
            cat ${FungAMR}/${SPECIES}/${QUERYPROT}.faa ${OUTWD}/${prot_query_name}.${counter}.faa > ${OUTWD}/tmp/${prot_query_name}.${counter}_prot2aln.faa
            mafft --thread ${NCPUS} --amino --auto ${OUTWD}/tmp/${prot_query_name}.${counter}_prot2aln.faa > ${OUTWD}/tmp/${prot_query_name}.${counter}.aln 2>/dev/null
            multi2single_line_fasta ${OUTWD}/tmp/${prot_query_name}.${counter}.aln > ${OUTWD}/tmp/${prot_query_name}.${counter}.oneline.aln
        fi
        let counter++
    done
done
echo -e "${COL_green}Done! (step 3/4)${COL_RESET}"

# 4. Look for mutations in AMR positions
echo -e "${COL_yellow}Inspecting mutations potentially causing AMR (step 4/4)${COL_RESET}"
for QUERYPROT in $(<${OUTWD}/tmp/queries_list.tmp); do
    prot_query_name="${INGENOME}_${QUERYPROT}"
    num_features=$(ls ${OUTWD}/${prot_query_name}.*.faa | wc -l)
    counter=1
    until [ $counter -gt $num_features ]; do
        if [ -s "${OUTWD}/${prot_query_name}.${counter}.blastp.txt" ]; then
            align_file=${OUTWD}/tmp/${prot_query_name}.${counter}.oneline.aln
            chroquetas_db=${FungAMR}/${SPECIES}/${QUERYPROT}.txt
            prot_subject_name=$(head -n 1 ${FungAMR}/${SPECIES}/${QUERYPROT}.faa | sed "s/ .*//" | sed "s/^>//")
            if [[ "$INPUT_FORMAT" == "prot" ]]; then
                prot_query_name=$(head -n 1 ${OUTWD}/${prot_query_name}.${counter}.faa | sed "s/ .*//" | sed "s/^>//")
            fi
            echo -e "Position\tReference\tQuery\tResult\tFungicides" > ${OUTWD}/${INGENOME}.ChroQueTaS.${QUERYPROT}.${counter}.tsv
            for mutpos in $(cut -f 1 ${chroquetas_db} | tail -n+2 | awk '!x[$0]++'); do
                amr_mutation=$(grep -P "^${mutpos}\t" ${chroquetas_db} | cut -f 3  | tr '\n' ',' | sed "s/,$/\n/" | sed "s/,//g")
                reference_aa=$(grep -P "^${mutpos}\t" ${chroquetas_db} | cut -f 2 | awk '!x[$0]++')
                aa_in_query=$(get_aa_from_pos ${align_file} ${prot_query_name} ${mutpos})
                aa_in_subject=$(get_aa_from_pos ${align_file} ${prot_subject_name} ${mutpos}) # some subject have AMR, use ${reference_aa} instead for reporting
                if [[ ! -z "${aa_in_query}" ]]; then
                    if [[ "${amr_mutation}" == *"${aa_in_query}"* ]]; then #match if string contains substring, for multiple entries per position in database
                        echo -e "${mutpos}\t${reference_aa}\t${aa_in_query}\tFungAMR MUTATION\t$(grep -P "^${mutpos}\t${aa_in_query}\t" <(cut -f 1,3,4 ${chroquetas_db}) | cut -f 3)" >> ${OUTWD}/${INGENOME}.ChroQueTaS.${QUERYPROT}.${counter}.tsv
                    else
                        if [[ "${aa_in_query}" == "${aa_in_subject}" ]]; then
                            echo -e "${mutpos}\t${aa_in_subject}\t${aa_in_query}\tNo mutation\tNA" >> ${OUTWD}/${INGENOME}.ChroQueTaS.${QUERYPROT}.${counter}.tsv
                        else
                            if [[ "${aa_in_query}" == "-" ]]; then
                                echo -e "${mutpos}\t${aa_in_subject}\t${aa_in_query}\tNo alignment\tNA" >> ${OUTWD}/${INGENOME}.ChroQueTaS.${QUERYPROT}.${counter}.tsv
                            else
                                echo -e "${mutpos}\t${aa_in_subject}\t${aa_in_query}\tNew mutation\tUnknown" >> ${OUTWD}/${INGENOME}.ChroQueTaS.${QUERYPROT}.${counter}.tsv
                            fi
                        fi
                    fi
                else
                    echo -e "${mutpos}\t${aa_in_subject}\t${aa_in_query}\tPosition not found\tNA" >> ${OUTWD}/${INGENOME}.ChroQueTaS.${QUERYPROT}.${counter}.tsv
                fi
            done
            # make summary file
            for total_mut in $(grep -P "\tFungAMR MUTATION\t" ${OUTWD}/${INGENOME}.ChroQueTaS.${QUERYPROT}.${counter}.tsv | cut -f 1); do
                echo -e "${QUERYPROT}\t${counter}" >> ${OUTWD}/tmp/1.tmp
            done
            grep -P "\tFungAMR MUTATION\t" ${OUTWD}/${INGENOME}.ChroQueTaS.${QUERYPROT}.${counter}.tsv | cut -f 1,2,3,5 >> ${OUTWD}/tmp/2.tmp
            for total_mut in $(grep -P "\tNew mutation\t" ${OUTWD}/${INGENOME}.ChroQueTaS.${QUERYPROT}.${counter}.tsv | cut -f 1); do
                echo -e "${QUERYPROT}\t${counter}" >> ${OUTWD}/tmp/1.tmp
            done
            grep -P "\tNew mutation\t" ${OUTWD}/${INGENOME}.ChroQueTaS.${QUERYPROT}.${counter}.tsv | cut -f 1,2,3,4 >> ${OUTWD}/tmp/2.tmp
            if [[ -s "${OUTWD}/tmp/1.tmp" && -s "${OUTWD}/tmp/2.tmp" ]]; then
                paste ${OUTWD}/tmp/1.tmp ${OUTWD}/tmp/2.tmp >> ${OUTWD}/${INGENOME}.ChroQueTaS.AMR_summary.txt
                rm ${OUTWD}/tmp/1.tmp ${OUTWD}/tmp/2.tmp
            fi
        fi
        let counter++
    done
    if [ -s "${OUTWD}/${INGENOME}.ChroQueTaS.AMR_summary.txt" ]; then
        echo -e "${QUERYPROT}\t$(grep -P "^${QUERYPROT}\t" ${OUTWD}/${INGENOME}.ChroQueTaS.AMR_summary.txt | grep -vcP "\tNew mutation$")\t$(grep -P "^${QUERYPROT}\t" ${OUTWD}/${INGENOME}.ChroQueTaS.AMR_summary.txt | grep -cP "\tNew mutation$")" >> ${OUTWD}/${INGENOME}.ChroQueTaS.AMR_stats.txt
    fi
done
if [[ -s "${OUTWD}/${INGENOME}.ChroQueTaS.AMR_summary.txt" && -s "${OUTWD}/${INGENOME}.ChroQueTaS.AMR_stats.txt" ]]; then
    sed -i "1iProtein\tFragment\tPosition_reference\tAA_reference\tAA_query\tFungicide_resistance" ${OUTWD}/${INGENOME}.ChroQueTaS.AMR_summary.txt
    sed -i "1iProtein\tFungAMR_mutations\tNew_mutations" ${OUTWD}/${INGENOME}.ChroQueTaS.AMR_stats.txt

    echo -e "${COL_green}Done! (step 4/4)${COL_RESET}\n\n -FungAMR mutations found: $(tail -n+2 ${OUTWD}/${INGENOME}.ChroQueTaS.AMR_summary.txt | grep -vcP "\tNew mutation$")\n -New mutations found: $(tail -n+2 ${OUTWD}/${INGENOME}.ChroQueTaS.AMR_summary.txt | grep -cP "\tNew mutation$")\n\nThanks for using ChroQueTas!\n"
else
    echo "No AMR mutations found in ${INGENOME}" > ${OUTWD}/${INGENOME}.ChroQueTaS.AMR_summary.txt
    echo -e "${COL_green}Done! (step 4/4)${COL_RESET}\n\nNo mutations found\n\nThanks for using ChroQueTas!\n"
fi
echo -e "\n${COL_yellow}PLEASE NOTE: the mutations reported by ChroQueTas must be considered according their confidence scores, where different combinations might exist.\n\nSee the main repositories for further details:\n -https://github.com/nmquijada/ChroQueTas\n -https://card.mcmaster.ca/fungamrhome${COL_RESET}\n"    
