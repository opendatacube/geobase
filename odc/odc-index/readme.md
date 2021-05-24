odc-index
=========

Sample docker for minimal deployment of datacube using service.

This one has:

- `aws` CLI tools
- `datacube` from `opendatacube/datacube-core`
- `s3-find`, `s3-to-tar` and `dc-index-from-tar` from `opendatacube/odc-tools`


## Build

```
make dkr
```

## Run

Pass in database details via `DATACUBE_DB_URL` environment variable

```
docker run --rm -ti \
 -e DATACUBE_DB_URL="postgresql://username:password@dbhost:5432/database" \
 odc-index -- \
 datacube system check
```

## Customizing

1. Edit `requirements.txt` to add/remove packages you need
2. Edit `constraints.txt`
3. Edit `Dockerfile` to add/remove extra packages
4. Optionally edit `with_bootstrap` if you need to do extra steps
