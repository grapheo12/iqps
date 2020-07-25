Installation
############

Installation can be easily done using Docker.

Source Installation is a lengthy process, the notes for the same are `here <SourceInstall.html>`_.

To install with Docker, first install git, Docker-CE and docker-compose (Install scripts work only on Unix based systems)

Follow the steps given in the official website of Docker. This varies from OS to OS.

Although, it is advisable not to use the default docker versions available in your OS's repos,
unless the Docker docs tell you to do so.

Once everything is installed, follow the following steps:

Steps
=====

1. Clone the repository:

   .. code-block:: bash

    git clone https://github.com/grapheo12/iqps.git
    cd iqps

#. Go to https://developers.google.com/drive/api/v3/quickstart/python. Click on ``Enable Drive API`` then click ``Create`` after selecting Desktop App in the modal.
   It will generate a ``credentials.json`` file. Move it to ``iqps/conf`` folder inside the repo.

#. Now in Google Drive top-level directory, open a new folder called (for example) ``iqps_static``. This is where the uploaded question papers go.

#. Run the install script for the first time:

   .. code-block:: bash

    ./install.sh

This will ask for app permissions. Sign in with the account you used in step-3. Accept all risks.

#. You can move the project folder to the intended app server now, or (for development) you can keep it in the local machine.
   Run the install script **FOR THE SECOND TIME**. Provide the details as asked.

#. Wait till the logs look like following:

   .. code-block:: bash

    db_1   | 2020-05-25 16:37:33 0 [Note] mysqld: ready for connections.
    db_1   | Version: '10.4.12-MariaDB-1:10.4.12+maria~bionic'  socket: '/var/run/mysqld/mysqld.sock'  port: 3306  mariadb.org binary distribution

Then kill the process by hitting ``CTRL+C``.

#. Run the initialization script. It will ask for creation of super-user account:

   .. code-block:: bash

    ./init.sh

#. Run (and daemonize) the app by executing:

   .. code-block:: bash

    docker-compose up -d

#. You can also stop the service by running:

   .. code-block:: bash

    docker-compose down

The next step is to configure a Server eg, Apache or Nginx to act as a Reverse-Proxy and serve the static files.

However, if you want to bring up a development system, setting up a server is unnecessary.
To do that, while the server is down, change ``MODE=prod`` to ``MODE=dev`` in ``iqps/conf/app.env``.
Also, in ``docker-compose.yml`` change the line ``command: gunicorn iqps.wsgi -w 4 -b 0.0.0.0:8000 --access-logfile /var/log/iqps/gunicorn.log``
to ``command: python manage.py runserver 0.0.0.0:8000``.

