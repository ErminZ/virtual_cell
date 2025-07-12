# virtual_cell
Train a model to predict the effect on a cell of silencing a gene using CRISPR.

## Intro

### STATE docker Installation

Run the command line where you save the Dockerfile.

`docker build -t state-model:v1 .`

Test STATE installation

`docker run -it -v $(pwd):/workspace state-model:v1 state --help`

GPU add `--gpus all`

```
docker run -it --gpus all -v $(pwd):/workspace state-model:v1 state --help
docker: Error response from daemon: could not select device driver "" with capabilities: [[gpu]]
```

## Run Inference
1. To run inferecne for embedding

```
state emb transform \
  --model-folder SE-600M \
  --input state_pbmc_split/test.h5ad \
  --output state_pbmc_split/test_se.h5ad
```

2. To run inferecne for STATE Transition Model

```
state tx infer \
  --model_dir ST-Parse \
  --checkpoint ST-Parse/final.ckpt \
  --adata state_pbmc_split/test_se.h5ad \
  --output pred_gene.h5ad \
  --embed_key X_hvg \
  --pert_col perturbation \
  --celltype_col context \
  --batch_size 64
```

3. Evaluation

```
cell-eval run \
  -ap pred_gene.h5ad \
  -ar state_pbmc_split/test_se.h5ad \
  --profile full \
  --control-pert non-targeting \
  --pert-col perturbation
```

