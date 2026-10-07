rule multiqc:
    input:
        raw_fastqc = expand(
            config["paths"]["results_dir"] + "/fastqc/raw/{sample}_{read}_fastqc.zip",
            sample=SAMPLES,
            read=["1", "2"]
        ),
        trimmed_fastqc = expand(
            config["paths"]["results_dir"] + "/fastqc/trimmed/{sample}_{read}.fastp.trim_fastqc.zip",
            sample=SAMPLES,
            read=["1", "2"]
        ) + expand(
            config["paths"]["results_dir"] + "/fastqc/trimmed/{sample}_singletons_fastqc.zip",
            sample=SAMPLES
        ),
        fastp_json = expand(
            config["paths"]["results_dir"] + "/fastp/{sample}.fastp.json",
            sample=SAMPLES
        )
    output:
        html = config["paths"]["results_dir"] + "/multiqc/qc_report.html"
    log:
        config["paths"]["logs_dir"] + "/multiqc/multiqc.log"
    shell:
        """
        mkdir -p {config[paths][results_dir]}/multiqc
        mkdir -p $(dirname {log})

        multiqc \
            {config[paths][results_dir]}/fastp \
            {config[paths][results_dir]}/fastqc \
            --config config/multiqc_config.yaml \
            --outdir {config[paths][results_dir]}/multiqc \
            --filename qc_report.html \
            --force \
            > {log} 2>&1
        """
