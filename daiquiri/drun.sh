#!/bin/bash

/opt/install-daiquiri.sh 

CMD ["gunicorn"  , "-b", "0.0.0.0:8000", "app:app"]
