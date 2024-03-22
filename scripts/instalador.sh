#/bin/bash

# control de errores y salidas
# exit1 salida por eleccion del usuario
# exit2 error en una instalacion

#funciones de errores y salidas
salida() {
	if test $1 -eq 1
 	   then
  	   exit 1
	fi
}
error() {
	if test $1 -eq 1
 	   then
	    zenity --error \
    		--text="error en algun punto de la instalacion."
  	   exit 2
	fi
}

zenity --question \
       --title="instalador" \
       --width=250 \
       --text="¿deseas instalar la paguina web en este equipo?"\
       --cancel-label="Abandonar"\
       --ok-label="seguir"

salida $?

	#realizamos el update
contra=$(zenity --password --title="Ingrese la contraseña del administrador" --timeout=10)
	echo "$contra" | sudo -S apt update &

(
	sleep 1
	echo "50"
	echo "# realizando update"; sleep 1
		if apt update
			then
			sleep 1
		fi
	echo "# Terminado"
	echo "100"

)|zenity --progress \
  	 --title="instalando" \
  	 --text="descargando paquetes" \
  	 --percentage=0

	#realizamos la instalaciones necesarias
	echo "$contra" | sudo -S apt install docker docker-compose -y &

(
	sleep 1
	echo "50"
	echo "# instalando doker"; sleep 1
		if apt update
			then
			sleep 1
		fi
	echo "# Terminado"
	echo "100"

)|zenity --progress \
  	 --title="instalador" \
  	 --text="inicializando doker" \
  	 --percentage=0



	#aqui  comprobamos que se haya instalado correctamente
	docker --version
  	 error $?
	docker-compose --version
  	 error $?


#creacion de los contenedores
	echo "$contra" | sudo -S docker-compose -f docker/docker-compose.yml up -d

(
	sleep 1
	echo "50"
	echo "# instalando los contenedores"; sleep 1
		if apt update
			then
			sleep 1
		fi
	echo "# Terminado"
	echo "100"

)|zenity --progress \
  	 --title="instalador" \
  	 --text="ejecutando contenedores" \
  	 --percentage=0



#sudo docker-compose -f ../docker/docker-compose.yml up -d
zenity --info \
       --title="instalador" \
       --width=250 \
       --text="los contenedores se han creado correctamente"

salida $?

#pregunta sobre si quieres añadir el usaurio al grupo
zenity --question \
       --title="instalador" \
       --width=350 \
       --text="¿Quieres añadir el tu usuario $USER al grupo de docker para no tener problemas con los permisos? si presionas (ACEPTAR) se añadira y se reiniciara el equipo "

# añadimos al usuario el grupo de docker y reiniciamos
cat /etc/group |grep docker| cut -d ":" -f4|grep $USER

if test $? -eq 0
	then
        zenity --info \
                --title="instalador" \
                --width=250 \
                --text="el usuario se encuentra en el grupo del docker"
	else
	echo "$contra" | sudo -S usermod -aG docker $USER

	zenity --info \
       		--title="instalador" \
       		--width=250 \
       		--text="hay que añadir el grupo de docker al usuario vamos a tener que reiniciar una vez echo esto vuelve a ejecutar el instalador"
#		reboot
fi
