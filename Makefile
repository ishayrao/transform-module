.PHONY: install clean module clean_module

# Use the existing venv from parent directory
VENV_DIR = ../.venv
PYTHON = $(VENV_DIR)/bin/python
PIP = $(VENV_DIR)/bin/pip

install: $(VENV_DIR)
	$(PIP) install -r requirements.txt
	
$(VENV_DIR):
	python3 -m venv $(VENV_DIR)

clean:
	rm -rf $(VENV_DIR)
	rm -rf __pycache__
	rm -rf .pytest_cache
	rm -rf *.egg-info
	rm -rf build dist
	find . -type d -name "__pycache__" -exec rm -rf {} +

# module archive for distribution
module.tar.gz: install
	tar -czf module.tar.gz \
		requirements.txt \
		src/ \
		meta.json

module: install
	$(PYTHON) -m PyInstaller src/main.py --onefile

clean_module:
	rm -rf dist
	rm -rf build
	rm -rf *.spec

# does not have target for torch that runs with orin gpu yet