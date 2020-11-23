rule sample_notears_linear_gaussian_data:
    input:
        bn="{output_dir}/bn/notears/{edge_params}/mean={mean}/variance={variance}/{rest}/adjmat=/{adjmat}.csv"
    output:
        data="{output_dir}/data" \
             "/adjmat=/{adjmat}"\
             "/bn=/notears/{edge_params}/" \
             "mean={mean}/" \
             "variance={variance}/" \
             "{rest}/"
             "data=/standard_sampling/" \
             "n={n}/" \
             "seed={replicate}.csv"
    singularity:
        docker_image("notears")
    shell:
        "python scripts/notears/simulate_from_dag_lg.py " \
        "--filename {output.data} " \
        "--weighted_adjmat_filename {input.bn} " \        
        "--mean {wildcards.mean} " \
        "--variance {wildcards.variance} " \
        "--n_samples {wildcards.n} " \
        "--seed {wildcards.replicate}"

rule sample_bindata:
    input:
        bn="{output_dir}/bn/generateBinaryBN/{bn}/adjmat=/{adjmat}.rds"
    output:
        data="{output_dir}/data" \
             "/adjmat=/{adjmat}"\
             "/bn=/generateBinaryBN/{bn}"\
             "/data=/standard_sampling/n={n}/seed={replicate}.csv"
    shell:
        "Rscript scripts/sample_data_with_range_header.R " \
        "--filename {output.data} " \
        "--filename_bn {input.bn} " \
        "--samples {wildcards.n} " \
        "--seed {wildcards.replicate}"

rule copy_fixed_data:
    input:
        "{output_dir}/data/mydatasets/{filename}" # this ensures that the file exists and is copied again if changed.
    output:
        data="{output_dir}/data/adjmat=/{adjmat}/bn=/None/data=/fixed/filename={filename}/n={n}/seed={replicate}.csv"
    shell:\
        "mkdir -p {wildcards.output_dir}/data/adjmat=/{wildcards.adjmat}/bn=/None/data=/fixed/filename={wildcards.filename}/n={wildcards.n} && "\
        "cp {input} {output.data}"

rule sample_bnfit_data:
    input:        
        bn="{output_dir}/bn/bn.fit_networks/{bn}"        
    output:
        data="{output_dir}/data/adjmat=/{adjmat}/bn=/bn.fit_networks/{bn}/data=/standard_sampling/n={n}/seed={replicate}.csv"
    shell:
        "Rscript scripts/sample_from_bnlearn_bn.R " \
        "--filename {output.data} " \
        "--filename_bn {input.bn} " \
        "--samples {wildcards.n} " \
        "--seed {wildcards.replicate}"