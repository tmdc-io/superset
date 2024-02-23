#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Python version installed; we need 3.9-3.11
PYTHON=`command -v python3.11 || command -v python3.10 || command -v python3.9`

.PHONY: install superset venv pre-commit

install: superset pre-commit

superset:
	# Install external dependencies
	pip install -r requirements/local.txt

	# Install Superset in editable (development) mode
	pip install -e .

	# Create an admin user in your metadata database
	superset fab create-admin \
                    --username admin \
                    --firstname "Admin I."\
                    --lastname Strator \
                    --email admin@superset.io \
                    --password general

	# Initialize the database
	superset db upgrade

	# Create default roles and permissions
	superset init

	# Load some data to play with
	superset load-examples

	# Install node packages
	cd superset-frontend; npm ci

update: update-py update-js

update-py:
	# Install external dependencies
	pip install -r requirements/local.txt

	# Install Superset in editable (development) mode
	pip install -e .

	# Initialize the database
	superset db upgrade

	# Create default roles and permissions
	superset init

update-js:
	# Install js packages
	cd superset-frontend; npm ci

venv:
	# Create a virtual environment and activate it (recommended)
	if ! [ -x "${PYTHON}" ]; then echo "You need Python 3.9, 3.10 or 3.11 installed"; exit 1; fi
	test -d venv || ${PYTHON} -m venv venv # setup a python3 virtualenv
	. venv/bin/activate

activate:
	. venv/bin/activate

pre-commit:
	# setup pre commit dependencies
	pip3 install -r requirements/integration.txt
	pre-commit install

format: py-format js-format

py-format: pre-commit
	pre-commit run black --all-files

py-lint: pre-commit
	pylint -j 0 superset

js-format:
	cd superset-frontend; npm run prettier

flask-app:
	flask run -p 8088 --with-threads --reload --debugger

node-app:
	cd superset-frontend; npm run dev-server

build-cypress:
	cd superset-frontend; npm run build-instrumented
	cd superset-frontend/cypress-base; npm ci

open-cypress:
	if ! [ $(port) ]; then cd superset-frontend/cypress-base; CYPRESS_BASE_URL=http://localhost:9000 npm run cypress open; fi
	cd superset-frontend/cypress-base; CYPRESS_BASE_URL=http://localhost:$(port) npm run cypress open

report-celery-worker:
	celery --app=superset.tasks.celery_app:app worker

report-celery-beat:
	celery --app=superset.tasks.celery_app:app beat --pidfile /tmp/celerybeat.pid --schedule /tmp/celerybeat-schedulecd

admin-user:
	superset fab create-admin

#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Python version installed; we need 3.9-3.11
PYTHON=`command -v python3.11 || command -v python3.10 || command -v python3.9`

.PHONY: install superset venv pre-commit

install: superset pre-commit

superset:
	# Install external dependencies
	pip install -r requirements/local.txt

	# Install Superset in editable (development) mode
	pip install -e .

	# Create an admin user in your metadata database
	superset fab create-admin \
                    --username admin \
                    --firstname "Admin I."\
                    --lastname Strator \
                    --email admin@superset.io \
                    --password general

	# Initialize the database
	superset db upgrade

	# Create default roles and permissions
	superset init

	# Load some data to play with
	superset load-examples

	# Install node packages
	cd superset-frontend; npm ci

update: update-py update-js

update-py:
	# Install external dependencies
	pip install -r requirements/local.txt

	# Install Superset in editable (development) mode
	pip install -e .

	# Initialize the database
	superset db upgrade

	# Create default roles and permissions
	superset init

update-js:
	# Install js packages
	cd superset-frontend; npm ci

venv:
	# Create a virtual environment and activate it (recommended)
	if ! [ -x "${PYTHON}" ]; then echo "You need Python 3.9, 3.10 or 3.11 installed"; exit 1; fi
	test -d venv || ${PYTHON} -m venv venv # setup a python3 virtualenv
	. venv/bin/activate

activate:
	. venv/bin/activate

pre-commit:
	# setup pre commit dependencies
	pip3 install -r requirements/integration.txt
	pre-commit install

format: py-format js-format

py-format: pre-commit
	pre-commit run black --all-files

py-lint: pre-commit
	pylint -j 0 superset

js-format:
	cd superset-frontend; npm run prettier

flask-app:
	flask run -p 8088 --with-threads --reload --debugger

node-app:
	cd superset-frontend; npm run dev-server

build-cypress:
	cd superset-frontend; npm run build-instrumented
	cd superset-frontend/cypress-base; npm ci

open-cypress:
	if ! [ $(port) ]; then cd superset-frontend/cypress-base; CYPRESS_BASE_URL=http://localhost:9000 npm run cypress open; fi
	cd superset-frontend/cypress-base; CYPRESS_BASE_URL=http://localhost:$(port) npm run cypress open

report-celery-worker:
	celery --app=superset.tasks.celery_app:app worker

report-celery-beat:
	celery --app=superset.tasks.celery_app:app beat --pidfile /tmp/celerybeat.pid --schedule /tmp/celerybeat-schedulecd

admin-user:
	superset fab create-admin


CH_DIR = helm
DIR = superset
VERSION = ${TAG}
PACKAGED_CHART = ${DIR}-${VERSION}.tgz
ECR_DEFAULT_REGIONS = us-east-1

# Push OCI package

push-oci-chart:
	@echo
	echo "=== login to OCI registry ==="
	aws ecr-public get-login-password --region us-east-1 | helm3.14.0 registry login  --username AWS --password-stdin public.ecr.aws
	@echo
	@echo "=== package OCI chart ==="
	helm3.14.0 package ${CH_DIR}/${DIR}/ --version ${VERSION}
	@echo
	@echo "=== create repository ==="
	aws ecr-public describe-images --repository-name ${DIR} --region us-east-1 || aws ecr-public create-repository --repository-name ${DIR} --region us-east-1
	@echo
	@echo "=== push OCI chart ==="
	helm3.14.0 push ${PACKAGED_CHART} oci://public.ecr.aws/z2k6n2n9
	@echo
	@echo "=== logout of registry ==="
	helm3.14.0 registry logout public.ecr.aws
