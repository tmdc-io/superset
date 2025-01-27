## Create rubiklabs superset image

# Use superset-trino-themis-fix.Dockerfile file to create superset image

`docker buildx build --sbom=true --provenance=true --platform linux/amd64 --push -t rubiklabs/superset:4.1.1.d1 -f superset-trino-themis-fix.Dockerfile .`

We have created a custom trino-python-client wheel which enables to query from themis as well.
