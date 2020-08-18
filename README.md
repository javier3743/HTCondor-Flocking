# HTCondor-Flocking

### Pasos para el desliegue de las VM’s

    vagrant up

Se desplegaran 5 VM’s en separadas por en 2 redes y unidas por un router que representa la separación geográfica, en este router se realiza la traducción de direcciones y de puertos para poder llevar a cabo la unión de 2 pools de HTCondor. 

Las VM’s creadas son `master1` y `node1` pertenecientes a la red `172.22.52.0/24`, por otro lado `master2` y `node2` pertenecientes a la red `172.25.52.0/24`.

### Como testear la simulacion

Dentro de las máquinas virtuales se encuentra la carpeta /vagrant, donde está ubicada una sencilla prueba que nos ayudará a demostrar el flocking de los pools. Los archivos que conforman la prueba son `submit.condor` y `test.sh`.

    condor_submit submit.condor
    
Esto enviará a ejecutar el script `test.sh`, el cual devuelve el hostname de la máquina. Debemos ejecutar varias veces este comando para poder forzar a HTCondor a que realice la interacción con el otro pool.

Más información sobre esta simulación se encuentra en este Link: [Documento](https://docs.google.com/document/d/1ieidQu6s3zqzjIImLeydZZWa0oEJRKOHAhm3V9TRdls/edit?usp=sharing)

