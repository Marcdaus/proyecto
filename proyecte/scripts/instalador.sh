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
sudo=$(zenity --password --title="instalador" --text "Ingrese la contraseña del superusuario"--width=350)
#barra de instalacion
(
sleep 1
echo "$sudo" | pkexec apt update
echo "$sudo" | pkexec apt install docker docker-compose
echo "# actualizando e instalando paquetes necesarios"
echo "33"
#aqui  comprobamos que se haya instalado correctamente
docker --version
  error $?
docker-compose --version
  error $?
echo "# verificando que los paquetes esten en orden"
echo "66"
sleep 2
# añadimos al usuario el grupo de docker y reiniciamos
cat /etc/group |grep docker| cut -d ":" -f4|grep $USER
if test $? -eq 0
	then
        zenity --info \
                --title="instalador" \
                --width=250 \
                --text="el usuario se encuentra en el grupo del docker"
	else
	echo "$sudo" | pkexec usermod -aG docker $USER
	zenity --info \
       		--title="instalador" \
       		--width=250 \
       		--text="hay que añadir el grupo de docker al usuario vamos a tener que reiniciar una vez echo esto vuelve a ejecutar el instalador"
		reboot
fi
#creacion de los contenedores
docker-compose -f docker/docker-compose.yml up -d
 error $?

zenity --info \
       --title="instalador" \
       --width=350 \
       --text="Los contenedores se han instalado correctamente"
echo "# instalando docker-compose"
echo "100"
sleep 1
) |
zenity --progress \
  --title="instalador" \
  --text="Iniciando el proceso" \
  --percentage=0 \
  --width=350\
  --ok-label="seguir"



#sudo docker-compose -f ../docker/docker-compose.yml up -d
