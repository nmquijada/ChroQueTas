FROM continuumio/miniconda
WORKDIR /app
COPY . .

# Extract the database and move its contents up one level
RUN mkdir -p /app/FungAMR_db && \
    tar -xvzf /app/FungAMR_db/db-v20250811.tgz -C /app/FungAMR_db && \
    mv /app/FungAMR_db/db-v0.6.0/* /app/FungAMR_db/ && \
    rm -rf /app/FungAMR_db/db-v0.6.0 && \
    rm /app/FungAMR_db/db-v20250811.tgz
RUN rm /app/FungAMR_db/README.md

# Create the conda environment
RUN conda env create -f environment.yml

# Set up the shell and entrypoint
SHELL ["conda", "run", "-n", "ChroQueTas", "/bin/bash", "-c"]
ENV TERM=xterm-256color
ENTRYPOINT ["conda", "run", "-n", "ChroQueTas", "bash", "bin/ChroQueTas.sh"]
