tzdata baked by sqlite with only actively used tzs held in memory

TODO:

- [x] periodically build tzdata sqlite db in github actions (TODO remove hardcoded values, switch away tfrom tzdata for preprocessing)
- [ ] download sqlite db from github
- [ ] lz4 or gzip db
- [ ] read from sqlite with no sqlite cache
- [ ] store actively used tzs in memory
