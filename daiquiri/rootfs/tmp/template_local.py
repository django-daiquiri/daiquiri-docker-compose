import os
from . import BASE_DIR, TAP_SCHEMA

'''
Secret key, use something random in production
'''
SECRET_KEY = 'notaverysecretkey'

'''
Debug mode, don't use this in production
'''
DEBUG = True

# ADMINS = [
#     ('admin', 'admin@localhost')
# ]

'''
Use Celery to run tasks asyncronous
'''
ASYNC = True

'''
Use a CDN for the vendor css and js files
'''
VENDOR_CDN = False

'''
The list of URLs und which this application available
'''
ALLOWED_HOSTS = ['localhost', 'ip6-localhost', '127.0.0.1', '[::1]']
USE_X_FORWARDED_HOST = True
SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')

'''
The database connection to be used, see also:
http://rdmo.readthedocs.io/en/latest/configuration/databases.html
'''
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': "daiquiri_app",
        'USER': "daiquiri_app",
        'PASSWORD':  "daiquiri_app",
        'HOST':  "postgresapp",
        'PORT': "5432",
        },
    'data': {
        'ENGINE': 'django.db.backends.postgresql',
        'OPTIONS': {
            'options': '-c search_path=%s,public' % TAP_SCHEMA
        },
        'NAME': "daiquiri_app",
        'USER': "daiquiri_app",
        'PASSWORD':  "daiquiri_app",
        'HOST':  "postgresapp",
        'PORT': "5432",
    }
}

ADAPTER_DATABASE = 'daiquiri.core.adapter.database.postgres.PostgreSQLAdapter'
ADAPTER_DOWNLOAD = 'daiquiri.core.adapter.download.pgdump.PgDumpAdapter'

'''
Use a custom registration workflow
'''
# AUTH_SIGNUP = True

'''
E-Mail configuration, see also:
http://rdmo.readthedocs.io/en/latest/configuration/email.html
'''
# EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
# EMAIL_HOST = 'localhost'
# EMAIL_PORT = '25'
# EMAIL_HOST_USER = ''
# EMAIL_HOST_PASSWORD = ''
# EMAIL_USE_TLS = False
# EMAIL_USE_SSL = False
# DEFAULT_FROM_EMAIL = ''

# CACHES = {
#    'default': {
#        'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
#        'LOCATION': '127.0.0.1:11211',
#        'KEY_PREFIX': ''
#    }
# }

# CELERY_BROKER_URL = ''

SENDFILE_BACKEND = 'sendfile.backends.xsendfile'

LOGGING_DIR = os.environ['LOGGING_DIR']

QUERY_DOWNLOAD_DIR = os.environ['DOWNLOAD_DIR']


# WORDPRESS_PATH = ''
