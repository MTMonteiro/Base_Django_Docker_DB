#!/bin/bash

project_name="test_Django"
app="core"
dir_work=.

a=2

#if [ $a -eq 3 ]; then
[ -d $dir_work/$project_name ] && echo "projeto já existente" | exit
mkdir $dir_work/$project_name

# Criação do ambiente virtual
# Criação do ambiente virtual
#ambiente criado no script install_py
#virtualenv venv
source venv/bin/activate

pip3 install Django==2.2

cd $dir_work/$project_name
django-admin startproject $project_name .
django-admin startapp $app

# settings
sed -i 's/^ALLOWED_.*/ALLOWED_HOSTS = ["*"]/'  $project_name/settings.py
sed -i "40i\    '$app',"  $project_name/settings.py
sed -i "s/'DIRS'.*/'DIRS': ['templates'],/g"  $project_name/settings.py
sed -i "s/^LANGUAGE_CODE.*/LANGUAGE_CODE = 'pt-br'/"  $project_name/settings.py
sed -i "s/^TIME_ZONE.*/TIME_ZONE = 'America\/Sao_Paulo'/"  $project_name/settings.py

echo "
STATIC_ROOT = os.path.join(BASE_DIR, 'staticfiles')

MEDIA_URL = '/media/'
MEDIA_ROOT = os.path.join(BASE_DIR, 'media')
" >> $project_name/settings.py



# urls
sed -i "s/^from django.urls.*/from django.urls import path, include/"  $project_name/urls.py
sed -i "21i\    path('', include('$app.urls')),"  $project_name/urls.py

#fi
#cd $dir_work/$project_name

#app urls
echo "
from django.urls import path
from .views import index

urlpatterns = [
    path('', index, name='index'),
]
" > $app/urls.py

# views
echo "
def index(request):
    return render(request, 'index.html')
" >> $app/views.py

# index.html
mkdir $app/templates
mkdir $app/static/
mkdir $app/static/js
mkdir $app/static/css
mkdir $app/static/images

echo "
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
</head>
<body>
<h1>Base Django</h1>
</body>
</html>
" > $app/templates/index.html

python manage.py makemigrations
python manage.py migrate


#pip install -r requirements.txt
