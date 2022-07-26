# Copyright © 2021 Cask Data, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at

# http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.

import io
import json
import os
import requests
import subprocess
import xml.etree.ElementTree as ET
import zipfile
import shutil
import sys
import argparse
import urllib.request

def run_shell_command(cmd):
    process = subprocess.run(cmd.split(" "), stderr=subprocess.PIPE)
    if process.returncode != 0:
        print("Process completed with error: ", process.stderr)
    assert process.returncode == 0

# Parse command line optional arguments
parser=argparse.ArgumentParser()
parser.add_argument('--testRunner', help='TestRunner class to execute tests')
parser.add_argument('--module', help='Module for which tests need to be run')
args=parser.parse_args()

# Start CDAP sandbox
print("Downloading CDAP sandbox")
sandbox_url = "https://builds.cask.co/artifact/CDAP-BUT/shared/build-latestSuccessful/SDK/cdap/cdap-standalone/target/cdap-sandbox-6.8.0-SNAPSHOT.zip"
sandbox_dir = sandbox_url.split("/")[-1].split(".zip")[0]
r = requests.get(sandbox_url)
z = zipfile.ZipFile(io.BytesIO(r.content))
z.extractall("./sandbox")

print("cwd:", os.getcwd())
print("ls:", os.listdir())

print("Downloading jar")
gcs_jar_url = "https://storage.googleapis.com/hadoop-lib/gcs/gcs-connector-hadoop2-2.2.5.jar"
gcs_jar_fname = "abc-connector-hadoop2-2.2.5.jar"
urllib.request.urlretrieve(gcs_jar_url, gcs_jar_fname)

print("cwd:", os.getcwd())
print("ls:", os.listdir())


print("Start the sandbox")
