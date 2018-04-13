PYTHONPATH=/home/cryo/ssmith/cryo-det/software/CryoDetCmbHcd/python/smurf_setup sphinx-apidoc -f -o ./ ../../smurf_setup/
make html
rsync -avz --progress _build/html/* swh76@rice.stanford.edu:/home/swh76/afs-home/WWW/smurf_setup_docs/
