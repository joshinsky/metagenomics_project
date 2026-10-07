rule fastqc_raw:
    input:
        r1 = config["paths"]["raw_dir"] + "/{sample}_1.fastq.gz",
        r2 = config["paths"]["raw_dir"] + "/{sample}_2.fastq.gz"
    output:
        r1_html = config["paths"]["results_dir"] + "/fastqc/raw/{sample}_1_fastqc.html",
        r2_html = config["paths"]["results_dir"] + "/fastqc/raw/{sample}_2_fastqc.html",
        r1_zip = config["paths"]["results_dir"] + "/fastqc/raw/{sample}_1_fastqc.zip",
        r2_zip = config["paths"]["results_dir"] + "/fastqc/raw/{sample}_2_fastqc.zip"
    params:
        outdir = config["paths"]["results_dir"] + "/fastqc/raw"
    threads:
        config["threads"]["fastqc"]
    resources:
        mem_gb = config["resources"]["fastqc"]
    shell:
        """
        mkdir -p {params.outdir}
        fastqc \
            --outdir {params.outdir} \
            --threads {threads} \
            {input.r1} \
            {input.r2}
        """


rule fastp:
    input:
        r1 = config["paths"]["raw_dir"] + "/{sample}_1.fastq.gz",
        r2 = config["paths"]["raw_dir"] + "/{sample}_2.fastq.gz"
    output:
        r1 = config["paths"]["results_dir"] + "/fastp/{sample}_1.fastp.trim.fastq.gz",
        r2 = config["paths"]["results_dir"] + "/fastp/{sample}_2.fastp.trim.fastq.gz",
        singletons = config["paths"]["results_dir"] + "/fastp/{sample}_singletons.fastq.gz",
        html = config["paths"]["results_dir"] + "/fastp/{sample}.fastp.html",
        json = config["paths"]["results_dir"] + "/fastp/{sample}.fastp.json"
    params:
        outdir = config["paths"]["results_dir"] + "/fastp",
        quality = config["params"]["quality"],
        min_length = config["params"]["min_length"]
    threads:
        config["threads"]["fastp"]
    resources:
        mem_gb = config["resources"].get("fastp", 2)
    log:
        config["paths"]["logs_dir"] + "/fastp/{sample}.log"
    shell:
        """
        mkdir -p {params.outdir}
        mkdir -p $(dirname {log})

        fastp \
            --in1 {input.r1} \
            --in2 {input.r2} \
            --out1 {output.r1} \
            --out2 {output.r2} \
            --unpaired1 {output.singletons} \
            --unpaired2 {output.singletons} \
            --detect_adapter_for_pe \
            --qualified_quality_phred {params.quality} \
            --length_required {params.min_length} \
            --thread {threads} \
            --html {output.html} \
            --json {output.json} \
            > {log} 2>&1
        """


rule fastqc_trimmed:
    input:
        r1 = rules.fastp.output.r1,
        r2 = rules.fastp.output.r2,
        singletons = rules.fastp.output.singletons
    output:
        r1_html = config["paths"]["results_dir"] + "/fastqc/trimmed/{sample}_1.fastp.trim_fastqc.html",
        r2_html = config["paths"]["results_dir"] + "/fastqc/trimmed/{sample}_2.fastp.trim_fastqc.html",
        singletons_html = config["paths"]["results_dir"] + "/fastqc/trimmed/{sample}_singletons_fastqc.html",
        r1_zip = config["paths"]["results_dir"] + "/fastqc/trimmed/{sample}_1.fastp.trim_fastqc.zip",
        r2_zip = config["paths"]["results_dir"] + "/fastqc/trimmed/{sample}_2.fastp.trim_fastqc.zip",
        singletons_zip = config["paths"]["results_dir"] + "/fastqc/trimmed/{sample}_singletons_fastqc.zip"
    params:
        outdir = config["paths"]["results_dir"] + "/fastqc/trimmed"
    threads:
        config["threads"]["fastqc"]
    resources:
        mem_gb = config["resources"]["fastqc"]
    shell:
        """
        mkdir -p {params.outdir}
        fastqc \
            --outdir {params.outdir} \
            --threads {threads} \
            {input.r1} \
            {input.r2} \
            {input.singletons}
        """
