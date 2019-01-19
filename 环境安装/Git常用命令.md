

## 更新部分代码场景

sparse-checkout 简要更新

--ignore-skip-worktree-bits

In sparse checkout mode, `git checkout -- <paths>` would update only entries matched by <paths> and sparse patterns in $GIT_DIR/info/sparse-checkout. This option ignores the sparse patterns and adds back any files in <paths>.

```
git config core.sparsecheckout true
echo config >> .git/info/sparse-checkout
echo src >> .git/info/sparse-checkout
git remote add origin http://git.goupwith.com:81/hq.liu/hex-edms-connector-impl.git
git pull origin hex-edms-connector-impl-lizhengwu
```



## 打包时候过滤某些文件




These path-specific settings are called Git attributes and are set either in a .gitattributes file in one of your directories (normally the root of your project) or in the .git/info/attributes file if you don’t want the attributes file committed with your project.

```
vi .git/info/attributes 
lib/ export-ignore

git archive --format=zip -o connect.zip hex-edms-connector-impl-lizhengwu

hex-edms-connector-impl-lizhengwu
```

git archive --format=zip --prefix=git-docs/ HEAD:Documentation/ > git-1.4.0-docs.zip