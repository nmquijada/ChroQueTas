#! /bin/bash

##############
# ChroQueTaS #
##############

AUTHORS="Narciso M. Quijada, Alejandro J. Alcañiz, David Mendoza-Salido, Sibbe Bakker"
VERSION="0.4.2"
LASTMODIF="2024-10-23"

ChroQueTas=$0
while [ -h "$ChroQueTas" ]; do # resolve $ChroQueTas until the file is no longer a symlink
  ChroQueTasDIR="$( cd -P "$( dirname "$0" )" && pwd )"
  ChroQueTas="$(readlink "$ChroQueTas")"
  [[ $ChroQueTas != /* ]] && ChroQueTas="$ChroQueTasDIR/$ChroQueTas" # if $ChroQueTas is a symlink, resolve it relative to the path where the symlink file was located
done
ChroQueTasDIR="$( cd -P "$( dirname "$ChroQueTas" )" && pwd )"

# WORKNING VARIABLES
FungAMR=
INDIR=
INGENOME=
INGENOME_PATH=
INGENOME_SUFFIX=
MINID=75
MINCOV=75
NCPUS=1
OUTPUT=
QUERYPROT=
SCHEME=

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
    grep -A 1 "$2" $1 | grep -v "$2" | awk "{ print substr( \$0, $3, 1 ) }"
}
get_dash_pos () {
    grep -A 1 "${2}" ${1} | grep -v "${2}" | grep -ob "-" | sed "s/:-$//"
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

usage: $0 <options>

${COL_green}OBLIGATORY OPTIONS:${COL_RESET}
    -f/--fungamr        Path to FungAMR database formatted for ChroQueTas
    -g/--genome         Path to the genomes file
    -o/--output         Path and name of the output directory
    -s/--scheme         Type the scheme you would like to conduct the analysis on
                        Options available: 'Calbicans', 'Ztritici'

${COL_cyan}OTHER OPTIONS:${COL_RESET}
    --min_cov           Sequence alignment coverage (percent) required for the target protein to be considered (default=75) <integer>
    --min_id            Sequence alignment similarity (percent) required for the target protein to be considered (default=75) <integer>
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
    -f|--fungamr)
    if [ "$2" ]; then
        FungAMR=$2
        shift 2
        if [ ! -d "${FungAMR}" ]; then
            echo -e "\nERROR: ${FungAMR} doesn't exist! Please check \n"
            exit 1
        fi
        if [ ! "$(ls -A ${FungAMR})" ]; then
            echo -e "\nERROR: ${FungAMR} is empty! Please check \n"
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
            echo -e "\nERROR: ${INGENOME_PATH} doesn't exist or is empty! Please check \n"
            exit 1
        fi
    else
        echo -e '\nERROR: "-g/--genome" requires an argument\n'
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
    -s|--scheme)
    if [ "$2" ]; then
        if [ $2 == 'Calbicans' ] || [ $2 == 'Ztritici' ]; then
            SCHEME=$2
            shift 2
        else
            echo -e "\n${COL_red}ERROR: unknown option for '-s/--scheme'${COL_RESET}"
			echo -e "Available schemes: Calbicans, Ztritici\nArgument parsed: $2 \n"
		    exit 1
	    fi
    else
        echo -e "\n${COL_red}ERROR: '-s/--scheme' requires an argument${COL_RESET}"
        echo 'Available schemes: Calbicans, Ztritici'
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


# CHECK MANDATORY VARIABLES
if [ -z "$FungAMR" ] || [ -z "$INGENOME_PATH" ] || [ -z "$OUTPUT" ] || [ -z "$SCHEME" ]; then
	if [ -z "$FungAMR" ]; then
        usage
        echo -e "\n${COL_red}ERROR: '-f/--fungamr' option is needed!${COL_RESET}\n"
        exit 1
    fi
    if [ -z "$INGENOME_PATH" ]; then
        usage
        echo -e "\n${COL_red}ERROR: '-g/--genome' option is needed!${COL_RESET}\n"
        exit 1
    fi
    if [ -z "$OUTPUT" ]; then
        usage
        echo -e "\n${COL_red}ERROR: '-o/--output' option is needed!${COL_RESET}\n"
        exit 1
    fi
    if [ -z "$SCHEME" ]; then
        usage
        echo -e "\n${COL_red}ERROR: '-s/--scheme' option is needed!${COL_RESET}\n"
        exit 1
    fi
fi

# Check if all mandatory software are installed
for mysoft in miniprot blastp mafft; do
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

# Define genome name and extension
INGENOME_PATH_BASE=$(basename $INGENOME_PATH)
INGENOME_SUFFIX="${INGENOME_PATH_BASE##*.}" # miniprot works with gz but not with bz2 files
#INGENOME_SUFFIX="${INGENOME_PATH_BASE#*.}" # fasta.gz
if [[ "$INGENOME_SUFFIX"  == 'bz2' ]]; then
    echo -e "${COL_red}ERROR: ${INGENOME_PATH} is bzipped!${COL_RESET}\nOnly compressed and/or gzipped files are supported\nYou can uncompress your file by typing:\n\n"
    echo -e "bzip2 -d ${INGENOME_PATH}"
    exit 1
fi
if [[ "$INGENOME_SUFFIX"  == 'gz' ]]; then
    INGENOME="${INGENOME_PATH_BASE%%.*}"
else
    INGENOME="${INGENOME_PATH_BASE%.*}"
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
QUERYNUM=$(ls ${FungAMR}/${SCHEME}/*faa | wc -l)
echo -e "\nThe scheme ${SCHEME} has ${QUERYNUM} proteins associated with AMR\n"
# parallel?
mkdir ${OUTWD}/tmp/
if [ ! -d "${OUTWD}/tmp/" ]; then
    echo -e "\n${COL_red}ERROR: $OUTPUT could not be created in the selected location.${COL_RESET}\nPlease check\n"
    exit 1
fi
for QUERYPROT_PATH in $(ls ${FungAMR}/${SCHEME}/*faa); do
    QUERYPROT=$(basename ${QUERYPROT_PATH} .faa)
    echo ${QUERYPROT} >> ${OUTWD}/tmp/queries_list.tmp
done

# 1. Protein prediction and extraction
echo -e "${COL_yellow}Running protein prediction and extraction (step 1/4)${COL_RESET}"
# 1.1. Reference genome for miniprot
miniprot -t ${NCPUS} -d ${OUTWD}/tmp/${INGENOME}.mpi ${INGENOME_PATH} 2>/dev/null
for QUERYPROT in $(<${OUTWD}/tmp/queries_list.tmp); do
    prot_query_name="${INGENOME}_${QUERYPROT}"
    miniprot -t ${NCPUS} ${OUTWD}/tmp/${INGENOME}.mpi ${FungAMR}/${SCHEME}/${QUERYPROT}.faa --trans > ${OUTWD}/tmp/${prot_query_name}.tmp 2>/dev/null
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
        echo -e "${COL_red}ERROR: We could not extract ${QUERYPROT} from the genome...\nProtein will be discarded for further screening${COL_RESET}"
        sed -i "s/${QUERYPROT}//" ${OUTWD}/tmp/queries_list.tmp; sed -i "/^$/d" ${OUTWD}/tmp/queries_list.tmp
        #rm ${OUTWD}/${prot_query_name}.1.faa ${OUTWD}/${prot_query_name}.1.paf
    fi
done
if [  "$(ls ${OUTWD}/*.faa 2>/dev/null | wc -l )" -gt 0 ] ; then
    echo -e "${COL_green}Done! (step 1/4)${COL_RESET}"
else
    echo -e "\n${COL_red}ERROR: ChroQuetas could not extract the query proteins from the genome...\nExiting...${COL_RESET}\n"
    exit 1
fi

# 2. Run blast and report stats
echo -e "${COL_yellow}Calculating protein similarity with reference (step 2/4)${COL_RESET}"
for QUERYPROT in $(<${OUTWD}/tmp/queries_list.tmp); do
    prot_query_name="${INGENOME}_${QUERYPROT}"
    #num_features=$(ls ${OUTWD}/${prot_query_name}.+([0-9]).faa | wc -l)
    num_features=$(ls ${OUTWD}/${prot_query_name}.*.faa | wc -l)
    counter=1
    until [ $counter -gt $num_features ]; do
        blastp -query ${OUTWD}/${prot_query_name}.${counter}.faa -subject ${FungAMR}/${SCHEME}/${QUERYPROT}.faa -out ${OUTWD}/tmp/${prot_query_name}.${counter}.blastp.tmp -evalue 1E-10 -outfmt "6 qseqid sseqid qlen slen pident length gaps evalue bitscore qstart qend sstart send"
        cat ${OUTWD}/tmp/${prot_query_name}.${counter}.blastp.tmp | awk -v OFS="\t" -F "\t" '{print $0, $14=($6-$7)*100/$13}' | awk -v OFS="\t" -v MINID=${MINID} -F "\t" '($5 > MINID)' | awk -v OFS="\t" -v MINCOV=${MINCOV} -F "\t" '($14 > MINCOV)' | sed "1iQuery\tReference\tquery_length\tsubject_length\tperc_identity\tlength_alignment\tgaps\tevalue\tbitscore\tqstart\tqend\tsstart\tsend\tperc_coverage" | awk -v OFS="\t" -F "\t" '{print $1,$2,$5,$14,$8,$3,$4,$6,$7,$9,$10,$11,$12,$13}' > ${OUTWD}/${prot_query_name}.${counter}.blastp.txt
        if [[ $(cat ${OUTWD}/${prot_query_name}.${counter}.blastp.txt | wc -l) -lt 2 ]]; then
            rm ${OUTWD}/${prot_query_name}.${counter}.blastp.txt
        fi
        let counter++
    done
done
echo -e "${COL_green}Done! (step 2/4)${COL_RESET}"

# 3. MAFFT alignment
echo -e "${COL_yellow}Performing alignment with reference (step 3/4)${COL_RESET}"
for QUERYPROT in $(<${OUTWD}/tmp/queries_list.tmp); do
    prot_query_name="${INGENOME}_${QUERYPROT}"
    num_features=$(ls ${OUTWD}/${prot_query_name}.*.faa | wc -l)
    counter=1
    until [ $counter -gt $num_features ]; do
        if [ -s "${OUTWD}/${prot_query_name}.${counter}.blastp.txt" ]; then
            cat ${FungAMR}/${SCHEME}/${QUERYPROT}.faa ${OUTWD}/${prot_query_name}.${counter}.faa > ${OUTWD}/tmp/${prot_query_name}.${counter}_prot2aln.faa
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
            chroquetas_db=${FungAMR}/${SCHEME}/${QUERYPROT}.txt
            prot_subject_name=$(head -n 1 ${FungAMR}/${SCHEME}/${QUERYPROT}.faa | sed "s/ .*//" | sed "s/^>//")
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
        fi
        let counter++
    done
done
echo -e "${COL_green}Done! (step 4/4)${COL_RESET}\n\nThanks for using ChroQueTas!\n"
echo -e "\n${COL_yellow}PLEASE NOTE: the mutations reported by ChroQueTas are reported as 'FungAMR' mutation and are potential AMR mutations that must be compared with the level of evidence contained in the main database: https://github.com/Landrylab/FungAMR${COL_RESET}\n"
