# install and test

VENV_ACTIVATE=.venv/bin/activate

.venv/bin/activate:
	@echo "### Creating Python virtual environment ###"
	python3.9 -m venv .venv

js/.done: .venv/bin/activate
	. $(VENV_ACTIVATE) && \
	cd js && \
	npm run autogen && \
	pip install jupyterlab -q && \
	npm run build:all
	@touch $@

.venv/.done: js/.done
	@echo "### Installing Python dependencies ###"
	. $(VENV_ACTIVATE) && \
	pip install -e . -q
	@touch $@

test: .venv/.done
	. $(VENV_ACTIVATE) && \
	pip install nbval scikit-image ipywebrtc matplotlib && \
	python -m pytest -vv -l --nbval-lax --current-env .

run: js/.done .venv/.done
	. $(VENV_ACTIVATE) && \
	jupyter labextension link js/ && \
	jupyter lab --ip='*' --NotebookApp.token='' --NotebookApp.password=''

# remove all autogenerated files
clean:
	cd js && npm run clean
	rm -rf .venv
	find js/src -name "*autogen*" -exec rm {} +
	-rm -- pythreejs/**/__init__.py
	-rm -- js/src/**/index.js
	rm -rf pythreejs/static/
	-rm js/package-lock.json
	-rm js/yarn.lock
	rm -rf pythreejs/labextension