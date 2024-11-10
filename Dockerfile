FROM continuumio/miniconda3

ENV PYTHONUNBUFFERED 1
ENV DJANGO_SETTINGS_MODULE=geodjango_assignment.settings

# Ensure that everything is up-to-date
RUN apt-get -y update && apt-get -y upgrade
RUN conda update -n base conda && conda update -n base --all
RUN apt-get install -y binutils libproj-dev gdal-bin
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY ENV.yml /usr/src/app
RUN conda env create -n geodjango_assignment --file ENV.yml

RUN echo "conda activate geodjango_assignment" >> ~/.bashrc
SHELL ["/bin/bash", "--login", "-c"]

# Set up conda to match our test environment
RUN conda config --add channels conda-forge && conda config --set channel_priority strict
RUN cat ~/.condarc
RUN conda install uwsgi

COPY . /usr/src/app
RUN python manage.py collectstatic --no-input

EXPOSE 8001
CMD uwsgi --ini uwsgi.ini