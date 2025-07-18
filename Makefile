.PHONY: install clean module clean_module pytorch-wheel torchvision-wheel install-jetpack

# Use the existing venv from parent directory
VENV_DIR = ../.venv
PYTHON = $(VENV_DIR)/bin/python
PIP = $(VENV_DIR)/bin/pip
PYTORCH_WHEEL=torch-2.5.0a0+872d972e41.nv24.08.17622132-cp310-cp310-linux_aarch64.whl
PYTORCH_WHEEL_URL=https://developer.download.nvidia.com/compute/redist/jp/v61/pytorch/$(PYTORCH_WHEEL)

TORCHVISION_REPO=https://github.com/pytorch/vision 
TORCHVISION_WHEEL=torchvision-0.20.0a0+afc54f7-cp310-cp310-linux_aarch64.whl
TORCHVISION_VERSION=0.20.0

install: $(VENV_DIR)
	@echo "Installing requirements"
	$(PIP) install -r requirements.txt

$(VENV_DIR):
	@echo "Building python venv...""
	sudo apt install python3.10-venv
	sudo apt install python3-pip
	python3 -m venv $(VENV_DIR)

install-jetpack-: $(VENV_DIR)
	@echo "Installing JetPack requirements"
	$(PIP) install -r requirements-jetpack.txt
	@echo "Installing PyTorch custom wheel"
	$(MAKE) pytorch-wheel
	@echo "Installing TorchVision custom wheel"
	$(MAKE) torchvision-wheel

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

$(BUILD)/$(PYTORCH_WHEEL):
@echo "Making $(BUILD)/$(PYTORCH_WHEEL)"
wget  -P $(BUILD) $(PYTORCH_WHEEL_URL)


pytorch-wheel: $(BUILD)/$(PYTORCH_WHEEL)

$(BUILD)/$(TORCHVISION_WHEEL): $(VENV_DIR) $(BUILD)/$(PYTORCH_WHEEL)
	@echo "Installing dependencies for TorchVision"
	bin/first_run.sh
	bin/install_cusparselt.sh

	$(PYTHON) -m pip install --upgrade pip
	$(PYTHON) -m pip install wheel
	$(PYTHON) -m pip install 'numpy<2' $(BUILD)/$(PYTORCH_WHEEL)

	@echo "Cloning Torchvision"
	git clone --branch v${TORCHVISION_VERSION} --recursive --depth=1 $(TORCHVISION_REPO) $(BUILD)/torchvision

	@echo "Building torchvision wheel"
	cd $(BUILD)/torchvision && $(PYTHON) setup.py --verbose bdist_wheel --dist-dir ../

torchvision-wheel: $(BUILD)/$(TORCHVISION_WHEEL)