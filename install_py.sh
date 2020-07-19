#!/bin/bash
#
# 20200717
#
# Matheus Monteiro
# matheusmonteiroalves@id.uff.br
#
#set -vx
#py_version="3.7.7"
#check_py_version=$(echo "$py_version" | awk -F\. '{print$1"."$2}')

programname=$0

function usage {
    #echo "usage: $programname [-abch] [-f infile] [-o outfile]"
    echo "Versão do python invalida ou problemas de rede!"
    echo "usage: $programname list"
    echo "  list  -  show python versions"
    exit 1
}


check_distro(){
  # Centos
  cat /etc/os-release | grep -i "centos" > /dev/null 2>&1
  [ "$?" -eq "0" ] &&  distro=centos

  # Ubuntu | Debian
  cat /etc/os-release | egrep -i "Ubuntu|Debian" > /dev/null 2>&1
  [ "$?" -eq "0" ] &&  distro=ubuntu

  case $distro in
  centos)
    yum install gcc openssl-devel bzip2-devel libffi-devel wget # >&-

    ;;

  ubuntu|debian)
    apt install gcc build-essential libssl-dev libffi-dev # >&-
    [ "$?" -eq "100" ] && echo "Execute o script como ROOT !!!" && exit;
    ;;

  *)
    echo "distro indisponivel"
    exit

esac
}


###########
check_python(){
    echo "Python$check_py_version já está instalado, na versão $2"
    echo "deseja mudar para a versão $py_version ?(y/n)"

    response=$(read -sn1 character; echo ${character^^})
    while [[ $response  =~ [^YN] ]]; do
        echo  "Resposta invalida!"
        echo "Digite apenas y ou n !"
        response=$(read -sn1 character; echo ${character^^})
    done

    [ "$response" == "Y" ] && remove_python $check_py_version || exit
}
##############

virtualenv_create(){
    echo "Criando ambiente virtual"
    apt install python3-pip # >&-
    pip3 install virtualenv # >&-
    virtualenv -p python$check_py_version venv
}

remove_python(){
    rm -rf /usr/bin/python$1
    rm -rf /usr/lib/python$1
    rm -rf /usr/local/lib/python$1
}

# Centos python 3.7
# install_python distro version_python
install_python(){
    current_python=$(python$check_py_version -V) #> /dev/null 2>&1
    [ "$?" -eq "0" ] && check_python $current_python
    echo "iniciando intalação do python"
    cd /usr/src
    echo "Baixando o python"
    wget https://www.python.org/ftp/python/$py_version/Python-$py_version.tgz
    [ "$?" -ne "0" ] &&  usage

    tar xzf Python-$py_version.tgz
    cd Python-$py_version
    echo "Configurando..."

    if [ "$distro" == "centos"];then
        sudo LD_RUN_PATH=/usr/local/lib ./configure --enable-optimizations --enable-loadable-sqlite-extensions
        sudo LD_RUN_PATH=/usr/local/lib make altinstall
    else
        ./configure --enable-optimizations --enable-loadable-sqlite-extensions
        make altinstall
    fi

    #make
    #make install
    rm /usr/src/Python-$py_version.tgz
    python$check_py_version -V
    [ "$?" -eq "0" ] && echo "Python instalado com sucesso" || echo "Falha na instalação"
}

list_py_versions(){
  curl https://www.python.org/ftp/python/ | \
  awk '{print$2}'| awk -F \" '{print$2}' | \
  egrep "2|3" | tr -d \/
}

[ "$1" == "list" ] && list_py_versions

echo "Verificando sistema e instalando dependencias"
check_distro

echo "Informe a versão que deseja instalar:"
read py_version
check_py_version=$(echo "$py_version" | awk -F\. '{print$1"."$2}')


install_python

echo "deseja criar um ambiente virtual ?(s/n)"
read response
[ "$response" == "s" ] && virtualenv_create

