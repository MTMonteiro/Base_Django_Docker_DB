#!/bin/bash
#
# 20200717
#
# Matheus Monteiro
# matheusmonteiroalves@id.uff.br
#


# $1 = distro

#py_version="3.7.7"
#check_py_version="3.7"
py_version="3.8.4"
check_py_version="3.8"

programname=$0

function usage {
    #echo "usage: $programname [-abch] [-f infile] [-o outfile]"
    echo "usage: $programname list"
    echo "  list  -  show python versions"
    exit 1
}

usage

check_distro(){

  cat /etc/os-release | grep -i $1 > /dev/null 2>&1
  [ "$?" -eq "0" ] && echo "achou a distro"; distro=$1 || echo "não achou";

}
###########
check_python(){
    echo "Python$check_py_version já está instalado, na versão $1"
    response="value"
    while [ "$response" != "y" -o "$response" != "n" ]
    do
        echo "deseja mudar para a versão $py_version ?(y/n)"
        read response
    done
}
##############

# Centos python 3.7
# install_python distro version_python
install_python(){
#python$check_py_version -V > /dev/null 2>&1
#[ "$?" -eq "0" ] && check_python

case $1 in
  centos)
    yum install gcc openssl-devel bzip2-devel libffi-devel wget
    cd /usr/src
    wget https://www.python.org/ftp/python/$py_version/Python-$py_version.tgz
    tar xzf Python-$py_version.tgz
    cd Python-$py_version
    ./configure --enable-optimizations
    make altinstall
    rm /usr/src/Python-$py_version.tgz
    python$check_py_version -V
    ;;

  ubuntu|debian)
    apt install gcc build-essential libssl-dev libffi-dev
    cd /usr/src
    echo "Baixando o python"
    wget https://www.python.org/ftp/python/$py_version/Python-$py_version.tgz
    tar xzf Python-$py_version.tgz
    cd Python-$py_version
    echo "Configurando..."
    ./configure --enable-optimizations
    make altinstall
    rm /usr/src/Python-$py_version.tgz
    python$check_py_version -V
    [ "$?" -eq "0" ] && echo "Python instalado com sucesso" || echo "Falha na instalação"

    sudo apt install python3-pip
    sudo pip3 install virtualenv
    ;;

  *)
    echo "distro indisponivel"

esac
}

list_py_versions(){
  curl https://www.python.org/ftp/python/ | \
  awk '{print$2}'| awk -F \" '{print$2}' | \
  egrep "2|3" | tr -d \/
}

[ "$1" == "list" ] && list_py_versions

check_distro $1
echo "iniciando intalação do python"
install_python $distro
