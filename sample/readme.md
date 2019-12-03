Example Docker using geobase
============================

1. Build docker image

```
docker build --tag sample-test .
```

2. Check `rasterio`

```
docker run --rm -ti sample-test \
       rio --aws-no-sign-requests info --indent 2 \
       's3://landsat-pds/c1/L8/106/070/LC08_L1TP_106070_20180417_20180501_01_T1/LC08_L1TP_106070_20180417_20180501_01_T1_B1.TIF'
```

3. Check `pyproj`

```
docker run --rm -ti sample-test \
       python -m pyproj -v
```
