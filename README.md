Clone and then:


```
docker build ./
```

There are two optional arguments

```
snapshot: Specifies which snapshot to build
commit: Specifies which GHC commit to build (can be a tag/branch)
```

For example,

```
docker build ./  --build-arg commit=master
```

