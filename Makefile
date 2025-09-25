.PHONY: install run generate-password clean help

# Default target
help:
	@echo "Available targets:"
	@echo "  install      - Install Jupyter and dependencies"
	@echo "  run          - Run Jupyter Lab with password"
	@echo "  gen-password - Generate a new password hash"
	@echo "  clean        - Clean Python cache files"

install:
	pip install -r requirements.txt jupyterlab

run:
	jupyter lab \
	--ServerApp.ip=0.0.0.0 \
	--ServerApp.port=4777 \
	--ServerApp.allow_remote_access=True \
	--ServerApp.trust_xheaders=True \
	--no-browser \
	--ServerApp.preferred_dir=/media/acleda/DATA/code/tools/jupyter \
	--ServerApp.token='metythorn.123'
	
gen-password:
	@python3 gen_passwd.py

clean:
	find . -type f -name "*.pyc" -delete
	find . -type d -name "__pycache__" -delete
