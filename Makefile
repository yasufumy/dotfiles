install:
	sh etc/install

update:
	git pull origin master
	git submodule init
	git submodule update
	git submodule foreach git pull origin master
	sh etc/update
