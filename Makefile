install: dependencies
	git submodule update --init
	./dotfiles.py install

dependencies:
	sudo pip install -r requirements.txt
