# Code Challenge: Save data from SEPOMEX

## Descripción 

Este proyecto tiene dos versiones, la 1era que es la implementación y la 2do que es la mejora.

## Archivos

- ./lib/assets/postal_codes.xlsx ( versión completa )
- ./lib/assets/minimalist_cps.xlsx ( versión minimalista con 2 estados )
- ./lib/assets/postal_codes.txt

## Uso de Gemas 

- Roo
- Redis
- Pg

## Instalación

- bundle install

## Información clave

Esto es lo que se sabe sobre los datos contenidos:

Cada asentamiento tiene un código postal
Un código postal puede estar asignado a múltiples asentamientos (ejemplo, código postal 01030)
Un asentamiento puede pertenecer a una ciudad (ejemplo, código postal 1317)
No todos los asentamientos pertenecen a una ciudad (ejemplo, Los Negritos, código postal 20310)
Cada asentamiento tiene un tipo
Cada asentamiento pertenece a un municipio
Un mismo municipio puede contener varias ciudades (ejemplo, Muelegé)
Un municipio pertenece a un estado

## Version 1 "Exploramiento"

En esta versión use el archivo EXCEL de SEPOMEX y cree un task llamado así:

```bash
rake envia_ya:generate_postal_codes_v1
```

Gracias a la herramienta "Roo" pude recorrer cada sheet ( hoja ) del excel que me devolvía el nombre de cada **Estado** ( Ej: Aguascalientes ) y posteriormente por cada sheet ( hoja ) recorrer sus filas para obtener la información necesaria que es **Codigo Postal**, **Colonia**, **Municipio**, **Ciudad** y guardarla en la base de datos usando PostgreSQL.

### Fase exploración

Gracias al seeds.rb que venía en el proyecto me di cuenta de los pasos de ejecución que son estos:

- Se crea Country con el code "MX" y nos devuelve el "id"
- Se crea State seteandole el **nombre y el country_id**
- Se crea City seteandole el **nombre, country_id y state_id**
- Se crea Municipality seteandole el **nombre, country_id, state_id y city_id**
- Se crea un PostalCode seteandole el **code, state_id, country_id y municipality_id**
- Se crea un Neighborhood seteandole el **name, country_id, state_id, city_id, postal_code_id y municipality_id**

### Fase desarrollo

Con esa lista de pasos, se procede a desarrollarlo en el código que es :

- Preguntar si existe el Estado ( where ):
  -  En caso de que sí, almaceno el "ID"
  -  En caso de que no, creo el estado ( :name, :country_id ) y almaceno en variable su "id"

- Preguntar si existe la Ciudad ( where ):
  -  En caso de que sí, almaceno el "ID"
  -  En caso de que no, creo la ciudad ( :name, :state_id, :country_id )  y almaceno en variable su "id"

- Preguntar si existe el Municipio ( where ):
  -  En caso de que sí, almaceno el "ID"
  -  En caso de que no, creo el municipio ( :name, :state_id, ;city_id, :country_id ) y almaceno en variable su "id"

- Preguntar si existe el Codigo Postal ( where ):
  -  En caso de que sí, almaceno el "ID" y adicional :
      - Pregunto si en el state_id ó municipality_id hubo alguna modificación y en caso de que sí:
        - Actualizo el Codigo Postal ( update ) 
  -  En caso de que no, creo el codigo postal ( :code, :municipality_id, :state_id, :country_id ) y almaceno en variable su "id"

- Preguntar si existe la Colonia ( where ):
    -  En caso de que sí, almaceno el "ID" y adicional :
      - Pregunto si en el state_id ó municipality_id ó city_id hubo alguna modificación y en caso de que sí:
        - Actualizo la Colonia ( update )  
  -  En caso de que no, creo el codigo postal ( :code, :municipality_id, :state_id, :country_id ) y almaceno en variable su "id"

### Fase ejecución

Al momento de ejecutar este desarrollo con todos los codigos postales hubo un gran tiempo de espera de aproxidamente:

***1 hora y 50 minutos***

### Fase analítica

Hacer este proceso de hacer consultas where, create y update nos lleva a un total de llamadas aproxidamente 300,000 y esto nos da unas desventajas:

- Cada vez que tu base de datos tiene mas información, los select se vuelven mas lentos.
- Poder saturar tu base de datos debido a todos las llamadas continuas sin descanso.
- Costo de llamadas con AWS o algun proveedor de nube, te puede resultar muy caro.

### Fase de re-ingeniería

Aquí se incorpora nuestro heroe "Redis" que va ayudarle a su amigo "PostgreSQL" a toda esa carga y a reducir precios ( hablando de un escenario real ) y es que Redis nos permite guardar llave => valor ( Ej: "Mexico" => "2" ) y hacer mas rapidaz las llamadas hacía el, dandonos estas ventajas:

- Todos los datos de Redis residen en la memoria, lo que permite un acceso a datos de baja latencia y alto rendimiento
- A diferencia de las bases de datos tradicionales, los almacenes de datos en memoria no requieren un viaje al disco, lo que reduce la latencia del motor a microsegundos
- El almacén de datos en memoria permite soportar una cantidad mucho mayor de operaciones y ofrecer tiempos de respuesta más rápidos.
- El resultado es un desempeño increíblemente rápido y operaciones de lectura o escritura promedio que se ejecutan en menos de un milisegundo y una capacidad para procesar millones de operaciones por segundo.

### Fase de re-desarrollo

Se define un glosario de llaves que van a existir en el Redis:

**Estado**
**Estado>>Ciudad**
**Estado>>Ciudad>>Municipio**
**Estado>>Ciudad>>Municipio>>CodigoPostal**
**Estado>>Ciudad>>Municipio>>CodigoPostal>>Colonia**

Para evitar los espacios en blancos, signos raros, etc de cada uno de los campos se usa:

**String.parameterize** ( Ref: https://www.rubydoc.info/gems/activesupport/5.0.0.1/String:parameterize ) 

Así si llega un campo "Ciudad de Mexico" sera ahora "ciudad_de_mexico" y se guardara así en el Redis

El valor que se le asignara a cada llave va ser el "ID" entonces un estado quedaría así:

"ciudad_de_mexico" => "1"

En caso de no existir la llave, se procede a crear la información en la base de datos.

### Fase de ejecución #2

El resultado que se espero si fue positivo ya que el tiempo disminuyo por 40 minutos dandonos un aprox de:

**1 hora y 10 minutos**

Otra vez estuve pensando en como poder agilizar esta parte para disminuir el tiempo muy considerablemente y para esto vamos a pasarnos a la Version 2 :)

## Version 2 "Re y re y re ingeniería = todos felices "

### Fase re-ingeniería 

Note que cada fila que provenía del Excel me daba un ligero delay de 1 segundo, esto ocasionado por todas las filas que se estaban procesando. Entonces aquí ya la mejora no era por parte del redis o postgresql, sino de una lectura por milisegundos de cada fila.

Entonces SEPOMEX nos ofrece un archivo TXT que pesa menos y que en lectura es muchisisimo mas rapido que usar el Excel con columnas y filas y que aparte nos da la ventaja de que ya vienen enumerados por su codigo postal.

En esta versión use el archivo TXT de SEPOMEX y cree un task llamado así:

```bash
rake envia_ya:generate_postal_codes_v2
```

### Fase re-desarrollo

El problema al principio fue que en las colonias su codificación venía en ISO-8859-1 ocasionando que los acentos no vinieran correctamente.

Entonces gracias al objeto File en su 2do parametro se codifica el archivo a UTF-8 y se procede a recorrer cada linea del archivo.

Como ahora es linea x linea, entonces tuve que preguntar que si en las lineas existía "El Catálogo" ó "d_codigo" se omitiera y siguiera su transcurso.

El código que ya existía en la version 1 se traspasa a este, lo único que cambia es la forma de obtener la información y asignarselas a las variables.

### Fase de ejecución

Ahora si, ya teniendo en cuenta que ya reducimos el delay de lectura por columna y row de un excel + Redis, el tiempo fue algo super positivo y nos arrojo un resultado de

**28 minutos** 🙌🏼🏼🏼

<img width="290" alt="Screen Shot 2022-08-25 at 11 02 43" src="https://user-images.githubusercontent.com/16615287/186727726-c6491903-1d65-4dd9-958b-c25bb5936392.png">


# Conclusión

- Todas las fases de ejecución fueron usando todos los codigos postales.
- Por el tiempo de 3 días del code challenge me limito mucho a mejorar mas el rendimiento, pero para las siguientes etapas considero que ya el Ruby podría agregar un escalon de validación donde el guarde la llave y el valor y así en un escenario real, ya no estar haciendo tantos brincos hacía el Redis y el PostgreSQL
- Sobre las actualizaciones, considero que debe de crearse otro task donde obtenga los codigos postales de la base de datos y se haga una comparación contra el archivo, en caso de faltar codigos postales, se podrían borrar de la base de datos, en caso de que un codigo postal sea nuevo, tendría que agregarse a la base de datos. 









