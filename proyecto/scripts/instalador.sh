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
#esta funcion permitira esperar a que la descarga se complete para no ir con textos adelantados
pausa() {
zenity --info \
       --title="instalador" \
       --width=250 \
       --text="estamos instalando pulsa cerrar y espera a que parezca el mensaje de confirmacion"
       --ok-label="cerrar"
	wait $!

zenity --info \
       --title="instalador" \
       --width=250 \
       --text="se estan instalando los ultimos paquetes"
       --ok-label="cerrar"

}
zenity --question \
       --title="instalador" \
       --width=250 \
       --text="¿deseas instalar la paguina web en este equipo?"\
       --cancel-label="Abandonar"\
       --ok-label="seguir"


	#realizamos el update
contra=$(zenity --password --title="Ingrese la contraseña del administrador" --timeout=10)
	echo "$contra" | sudo -S apt update &
	pausa

(
	sleep 1
	echo "25"
	echo "# realizando update"; sleep 1
	echo "50";sleep 1
	echo "75";sleep 1
	echo "# Terminado"
	echo "100"

)|zenity --progress \
  	 --title="instalando" \
  	 --text="descargando paquetes" \
  	 --percentage=0

	#realizamos la instalaciones necesarias
	echo "$contra" | sudo -S apt install docker docker-compose -y &
	pausa
(
	sleep 1
	echo "25"
	echo "# instalando doker"; sleep 1
	echo "50";sleep 1
	echo "75";sleep 1
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
	pausa
(
	sleep 1
	echo "25"
	echo "# creando contenedores"; sleep 1
	echo "50";sleep 1
	echo "75";sleep 1
	echo "# Terminado"
	echo "100"

)|zenity --progress \
  	 --title="instalando" \
  	 --text="descargando paquetes" \
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
         exit 1
	else
	echo "$contra" | sudo -S usermod -aG docker $USER

	zenity --info \
       		--title="instalador" \
       		--width=250 \
       		--text="hay que añadir el grupo de docker al usuario vamos a tener que reiniciar una vez echo esto vuelve a ejecutar el instalador"
#		reboot
fi
