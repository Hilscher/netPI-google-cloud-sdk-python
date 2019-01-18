## Google Cloud SDK with Python example

Made for [netPI](https://www.netiot.com/netpi/), the Raspberry Pi 3B Architecture based industrial suited Open Edge Connectivity Ecosystem

### Debian with Google Cloud SDK, Python based example, SSH server and user root

The image provided hereunder deploys a container with installed Google Cloud SDK and a ready-to-use sample application connecting to your personal Google Cloud after a short setup.

Base of this image builds [debian](https://www.balena.io/docs/reference/base-images/base-images/) with enabled [SSH](https://en.wikipedia.org/wiki/Secure_Shell), created user 'root' and preinstalled SDK and gcloud command described in [Google's Tutorial](https://cloud.google.com/sdk/docs/#deb) with the sample from [here](https://github.com/GoogleCloudPlatform/python-docs-samples/tree/master/iot/api-client/mqtt_example).

Before using the sample you have to sign up with [Google Cloud Platform](https://cloud.google.com/) and create an account. At the time of image preparation Google offered a 12 month billing free ($300 free credits) trial period. This may change in future.

#### Container prerequisites

##### Port mapping

For remote login to the container across SSH the container's SSH port `22` needs to be mapped to any free netPI host port.

#### Getting started

STEP 1. Open netPI's landing page under `https://<netpi's ip address>`.

STEP 2. Click the Docker tile to open the [Portainer.io](http://portainer.io/) Docker management user interface.

STEP 3. Enter the following parameters under **Containers > Add Container**

* **Image**: `hilschernetpi/netpi-google-cloud-sdk-python`

* **Port mapping**: `Host "22" (any unused one) -> Container "22"` 

* **Restart policy"** : `always`

STEP 4. Press the button **Actions > Start/Deploy container**

Pulling the image may take a while (5-10mins). Sometimes it takes so long that a time out is indicated. In this case repeat the **Actions > Start/Deploy container** action.

#### Accessing

The container starts the SSH server automatically when started. Open a terminal connection to it with an SSH client such as [putty](http://www.putty.org/) using netPI's IP address at your mapped port.

Use the credentials `root` as user and `root` as password when asked and you are logged in as root user `root`.

For better documentation the following Google Cloud project settings are assumed as given. Yours may differ. Adjust them accordingly.

Project: My First Project
Project ID: verdant-cascade-211809
Device Registry: MyRaspberry
Region: europe-west1
Device: MyDevice
Pub/Sub Subscription: MySub
Pub/Sub Topic: MyEvents

##### Google Cloud Platform

The Google Cloud Platform welcomes you with a created `My First Project` already. Otherwise (if changed in future) create a project manually. A project is needed to proceed in any case.

STEP 1: In the project's navigation menu click `Home`. The page will show you the Project ID "verdant-cascade-211809". The ID is needed as reference always for any online services with the SDK.

STEP 2: In the navigation menu click `BIG DATA / IoT Core` and enable `IoT Core API`.

STEP 3: With the same dialog create a new [device registry](https://cloud.google.com/iot/docs/how-tos/devices). Enter the name `MyRaspberry` as Registry ID, select e.g. `europe-west1` as region, keep protocols MQTT and HTTP enabled. As `Default telemetry topic` create a new topic e.g.`MyEvents` as `projects/verdant-cascade-211809/topics/MyEvents` and select the same topic as `Device state topic`.

STEP 4: The same dialog will ask you to create a device as well. Ignore it. A device with a security certificate is being created and uploaded later online when walking through the SDK steps.

STEP 5: In the navigation menu click `BIG DATA / Pub/Sub` and enable `Pub/Sub API`. 

STEP 6: With the same dialog create a new topic named `MyEvents` as `/projects/verdant-cascade-211809/topics/MyEvents`. A subscription enabling pulling/pushing data to this topic will be added later during the SDK steps.

##### SDK

With the SDK the `gcloud` shell command is installed. Its call reference find [here](https://cloud.google.com/sdk/gcloud/reference/).

STEP 1: Use `gcloud auth login [ACCOUNT]` to authenticate gcloud against your google account (usually your email address). Authentication requires a one time verification process with a Web Browser and a key copy mechanism.

STEP 2: Set your current working project with `gcloud config set project verdant-cascade-211809`.

STEP 3: Create a privat/public key pair required for a secured communications with `openssl req -x509 -newkey rsa:2048 -keyout rsa_private.pem -nodes -out rsa_cert.pem`. The questions you can answer with `.` to leave blank except for the `Common Name` where you should enter a valid name like `MyDevice`.

STEP 4: Create a new device `MyDevice` with the just created public key with `gcloud iot devices create MyDevice --project=verdant-cascade-211809 --region=europe-west1 --registry=MyRaspberry --public-key path=rsa_cert.pem,type=rs256`.

STEP 5: Create a pub/sub topic and a subscription `gcloud pubsub subscriptions create projects/verdant-cascade-211809/subscriptions/MySub --topic=MyEvents`.

STEP 6: Start the python sample with `python cloudiot_mqtt_example.py --project_id=verdant-cascade-211809 --registry_id=MyRaspberry --cloud_region=europe-west1 --device_id=MyDevice --algorithm=RS256 --private_key_file=rsa_private.pem`.

STEP 7: To verify if data has been pushed to this subscription call `gcloud pubsub subscriptions pull projects/verdant-cascade-211809/subscriptions/MySub --auto-ack --limit=100`.

#### Automated build

The project complies with the scripting based [Dockerfile](https://docs.docker.com/engine/reference/builder/) method to build the image output file. Using this method is a precondition for an [automated](https://docs.docker.com/docker-hub/builds/) web based build process on DockerHub platform.

DockerHub web platform is x86 CPU based, but an ARM CPU coded output file is needed for Raspberry systems. This is why the Dockerfile includes the [balena](https://balena.io/blog/building-arm-containers-on-any-x86-machine-even-dockerhub/) steps.

#### License

View the license information for the software in the project. As with all Docker images, these likely also contain other software which may be under other licenses (such as Bash, etc from the base distribution, along with any direct or indirect dependencies of the primary software being contained).
As for any pre-built image usage, it is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.

[![N|Solid](http://www.hilscher.com/fileadmin/templates/doctima_2013/resources/Images/logo_hilscher.png)](http://www.hilscher.com)  Hilscher Gesellschaft fuer Systemautomation mbH  www.hilscher.com
