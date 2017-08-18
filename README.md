# Supported tags and respective `Dockerfile` links

- [`base` (*base/Dockerfile*)](https://github.com/twang2218/docker-zeppelin/blob/master/base/Dockerfile)
- [`common` (*common/Dockerfile*)](https://github.com/twang2218/docker-zeppelin/blob/master/common/Dockerfile)
- [`all` (*all/Dockerfile*)](https://github.com/twang2218/docker-zeppelin/blob/master/all/Dockerfile)

[![Build Status](https://travis-ci.org/twang2218/docker-zeppelin.svg?branch=master)](https://travis-ci.org/twang2218/docker-zeppelin)
[![Image Layers and Size](https://images.microbadger.com/badges/image/twang2218/docker-zeppelin.svg)](http://microbadger.com/images/twang2218/docker-zeppelin)
[![Deploy to Docker Cloud](https://files.cloud.docker.com/images/deploy-to-dockercloud.svg)](https://cloud.docker.com/stack/deploy/?repo=https://github.com/twang2218/docker-zeppelin)

# Apache Zeppelin Docker image

The image has 3 variations: `base`, `common`, and `all`.

* `base`: includes the interpreters less than 10MB: `angular,python,shell,bigquery,file,jdbc,kylin,livy,md,postgresql`;
* `common`: beside the interpreters included in the `base` image, it also includes the interpreters less than 50MB: `alluxio,cassandra,elasticsearch,ignite,lens`;
* `all`: It includes all the interpreters, so beside the interpreters listed above, the following interpreters are also included: `beam,hbase,pig,scio`

All data are stored in `/data` directory, such as:

* `ZEPPELIN_LOG_DIR`: `/data/log`
* `ZEPPELIN_PID_DIR`: `/data/run`
* `ZEPPELIN_NOTEBOOK_DIR`: `/data/notebook`

So, to persistent the data, a docker volume should be used to mount on the `/data` directory.

> If you want to mount `/data` to host directory, instead of docker volume, please note, the directory's owner uid is `501`, which is user `zeppelin` inside the container.

```bash
$ docker volume create zeppelin-data
$ docker run -d -v zeppelin-data:/data -p 8080:8080 twang2218/zeppelin:common
```

It's recommended to use `docker-compose` for the service, an example `docker-compose.yml` is provided for this purpose.
