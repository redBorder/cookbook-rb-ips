all: rpm

rpm:
	$(MAKE) -C packaging/rpm

clean:
	$(MAKE) -C packaging/rpm clean
rpmtest:
	$(MAKE) LATEST=`git stash create` -C packaging/rpm