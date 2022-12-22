CREATE TABLE temporadas (
	codigo			VARCHAR2(9),
	Nombre			VARCHAR2(35),
	fecha_inicio		DATE,
	fecha_fin		DATE,
	CONSTRAINT pk_temporadas PRIMARY KEY (codigo)
);	

CREATE TABLE regimenes (
	codigo VARCHAR2(9),
	nombre VARCHAR2(35),
	CONSTRAINT pk_regimenes PRIMARY KEY (codigo),
	CONSTRAINT contenido_codigo CHECK( codigo in ('AD','MP','PC','TI'))
);	

CREATE TABLE tipos_de_habitacion (
	codigo VARCHAR2(9),
	nombre VARCHAR2(35),
	CONSTRAINT pk_tipohabit PRIMARY KEY (codigo)
);	

CREATE TABLE habitaciones (
	numero VARCHAR2(4),
	codigotipo VARCHAR2(9),
	CONSTRAINT pk_habitaciones PRIMARY KEY (numero),
	CONSTRAINT fk_habitaciones FOREIGN KEY (codigotipo) REFERENCES tipos_de_habitacion(codigo)
);	

CREATE TABLE personas (
	nif	VARCHAR2(9),
	nombre VARCHAR2(35) CONSTRAINT nombre_obligatorio not null,
	apellidos VARCHAR2(35) CONSTRAINT apellidos_obligatorio not null,
	direccion VARCHAR2(150) CONSTRAINT direccion_obligatorio not null,
	localidad VARCHAR2(35) CONSTRAINT localidad_obligatorio not null,
	CONSTRAINT pk_personas PRIMARY KEY (nif),
	CONSTRAINT nif_valido CHECK (regexp_like (nif,'[0-9]{8}[A-Z]{1}') or regexp_like (nif, '[K,L,M,X,Y,Z]{1}[0-9]{7}[A-Z]{1}')),
  	CONSTRAINT localidades CHECK(localidad like '%(Salamanca)' or localidad like '%(Ávila)' or localidad like '%(Madrid)')
);	

CREATE TABLE estancias (
	codigo VARCHAR2(9),
	fecha_inicio DATE,
	fecha_fin DATE,
	numerohabitacion VARCHAR2(9),
	nifresponsable VARCHAR2(9),
	nifcliente VARCHAR2(9),
	codigoregimen VARCHAR2(9),
	CONSTRAINT pk_estancias PRIMARY KEY (codigo),
	CONSTRAINT unica_estancia unique (nifresponsable),
	CONSTRAINT fk_estanciasnumhab FOREIGN KEY (numerohabitacion) REFERENCES habitaciones(numero),
	CONSTRAINT fk_estanciasnifresp FOREIGN KEY (nifresponsable) REFERENCES personas(nif),
	CONSTRAINT fk_estanciasnifcli FOREIGN KEY (nifcliente) REFERENCES personas(nif),
	CONSTRAINT fk_estanciasregim FOREIGN KEY (codigoregimen) REFERENCES regimenes(codigo),
	CONSTRAINT fecha_salida CHECK( to_char(fecha_fin,'hh24:mi')<='21:00')
);	

CREATE TABLE tarifas (
	codigo VARCHAR2(9),
	codigotipohabitacion VARCHAR2(9),
	codigotemporada	VARCHAR2(9),
	codigoregimen VARCHAR2(9),
	preciopordia NUMBER(6,2),
	CONSTRAINT pk_tarifas PRIMARY KEY (codigo),
	CONSTRAINT fk_tarifastipo FOREIGN KEY (codigotipohabitacion) REFERENCES tipos_de_habitacion(codigo),
	CONSTRAINT fk_tarifasregimenes FOREIGN KEY (codigoregimen) REFERENCES regimenes(codigo),
	CONSTRAINT fk_tarifastempor FOREIGN KEY (codigotemporada) REFERENCES temporadas(codigo)
);	

CREATE TABLE facturas (
	numero VARCHAR2(9),
	codigoestancia VARCHAR2(9),
	fecha DATE,
	CONSTRAINT pk_facturas PRIMARY KEY (numero),
	CONSTRAINT fk_facturas FOREIGN KEY (codigoestancia) REFERENCES estancias (codigo)
);

CREATE TABLE gastos_extra (
	codigogasto	VARCHAR2(9),
	codigoestancia VARCHAR2(9),
	fecha DATE,
	concepto VARCHAR2(120),
	cuantia NUMBER(6,2),
	CONSTRAINT pk_gastext PRIMARY KEY (codigogasto),
	CONSTRAINT fk_gastext FOREIGN KEY (codigoestancia) REFERENCES estancias(codigo)
);


CREATE TABLE actividades (
	codigo VARCHAR2(9),
	nombre VARCHAR2(35),
	descripcion	VARCHAR2(140),
	precioporpersona NUMBER(6,2),
	comisionhotel NUMBER(6,2),
	costepersonaparahotel	NUMBER(6,2),
	CONSTRAINT pk_actividades PRIMARY KEY (codigo),
	CONSTRAINT codigo_valido CHECK( regexp_like( codigo, '[A-Z]{1}[0-9]{3}.*')),
	CONSTRAINT comisionhotel_inferior CHECK(comisionhotel <= precioporpersona*0.25)
);


CREATE TABLE actividadesrealizadas (
	codigoestancia VARCHAR2(9),
	codigoactividad VARCHAR2(9),
	fecha DATE,
	numpersonas	NUMBER(6,2) default 1,
	abonado VARCHAR2 (1) DEFAULT 'N',
	CONSTRAINT pk_actrealizadas PRIMARY KEY (codigoestancia, codigoactividad, fecha),
	CONSTRAINT fk_actrealestan FOREIGN KEY (codigoestancia) REFERENCES estancias(codigo),
	CONSTRAINT fk_actrealact FOREIGN KEY (codigoactividad) REFERENCES actividades(codigo),
  	CONSTRAINT descanso_activs CHECK(to_char(fecha, 'DAY') not like '%MON%' and to_char(fecha,'hh24:mi') not between '23:00' and '05:00')
);



----------------------------------------------------------------------------------------
---INSERCIÓN DE DATOS
----------------------------------------------------------------------------------------


---Temporadas -- codigo, nombre
INSERT INTO temporadas VALUES ('01','Baja', to_date('01-11-2022','DD-MM-YYYY'), to_date('31-03-2023','DD-MM-YYYY'));
INSERT INTO temporadas VALUES ('02','Alta', to_date('01-04-2022','DD-MM-YYYY'), to_date('31-10-2022','DD-MM-YYYY'));
INSERT INTO temporadas VALUES ('03','Especial', to_date('25-12-2022','DD-MM-YYYY'), to_date('06-01-2023','DD-MM-YYYY'));


---Regimenes -- codigo, nombre	
INSERT INTO regimenes VALUES ('AD','Alojamiento y Desayuno');
INSERT INTO regimenes VALUES ('MP','Media pension');
INSERT INTO regimenes VALUES ('PC','Pension completa');
INSERT INTO regimenes VALUES ('TI','Todo incluido');


---Tipos de habitacion -- codigo, nombre	
INSERT INTO tipos_de_habitacion VALUES ('01','Habitacion individual');
INSERT INTO tipos_de_habitacion VALUES ('02','Habitacion doble');
INSERT INTO tipos_de_habitacion VALUES ('03','Habitacion triple');


---Tarifas -- codigo, codigotipohabitacion, codigotemporada, codigoregimen, preciopordia
INSERT INTO tarifas VALUES ('00','01','01','AD',50);
INSERT INTO tarifas VALUES ('01','01','02','AD',70);
INSERT INTO tarifas VALUES ('02','01','03','AD',60);
INSERT INTO tarifas VALUES ('03','02','01','AD',60);
INSERT INTO tarifas VALUES ('04','02','02','AD',84);
INSERT INTO tarifas VALUES ('05','02','03','AD',72);
INSERT INTO tarifas VALUES ('06','03','01','AD',81);
INSERT INTO tarifas VALUES ('07','03','02','AD',115);
INSERT INTO tarifas VALUES ('08','03','03','AD',100);
INSERT INTO tarifas VALUES ('09','01','01','MP',35);
INSERT INTO tarifas VALUES ('10','01','02','MP',50);
INSERT INTO tarifas VALUES ('11','01','03','MP',40);
INSERT INTO tarifas VALUES ('12','02','01','MP',79);
INSERT INTO tarifas VALUES ('13','02','02','MP',119);
INSERT INTO tarifas VALUES ('14','02','03','MP',70);
INSERT INTO tarifas VALUES ('15','03','01','MP',43);
INSERT INTO tarifas VALUES ('16','03','02','MP',65);
INSERT INTO tarifas VALUES ('17','03','03','MP',52.5);
INSERT INTO tarifas VALUES ('18','01','01','PC',85);
INSERT INTO tarifas VALUES ('19','01','02','PC',102);
INSERT INTO tarifas VALUES ('20','01','03','PC',92.9);
INSERT INTO tarifas VALUES ('21','02','01','PC',80.5);
INSERT INTO tarifas VALUES ('22','02','02','PC',105.6);
INSERT INTO tarifas VALUES ('23','02','03','PC',93.5);
INSERT INTO tarifas VALUES ('24','03','01','PC',61.6);
INSERT INTO tarifas VALUES ('25','03','02','PC',110);
INSERT INTO tarifas VALUES ('26','03','03','PC',94.1);
INSERT INTO tarifas VALUES ('27','01','01','TI',79);
INSERT INTO tarifas VALUES ('28','01','02','TI',99);
INSERT INTO tarifas VALUES ('29','01','03','TI',86);
INSERT INTO tarifas VALUES ('30','02','01','TI',60);
INSERT INTO tarifas VALUES ('31','02','02','TI',95);
INSERT INTO tarifas VALUES ('32','02','03','TI',80);
INSERT INTO tarifas VALUES ('33','03','01','TI',60);
INSERT INTO tarifas VALUES ('34','03','02','TI',87);
INSERT INTO tarifas VALUES ('35','03','03','TI',70);


---Habitaciones -- numero, codigotipo
INSERT INTO habitaciones VALUES ('00','01');
INSERT INTO habitaciones VALUES ('01','02');
INSERT INTO habitaciones VALUES ('02','03');
INSERT INTO habitaciones VALUES ('03','01');
INSERT INTO habitaciones VALUES ('04','02');
INSERT INTO habitaciones VALUES ('05','02');
INSERT INTO habitaciones VALUES ('06','02');
INSERT INTO habitaciones VALUES ('07','02');
INSERT INTO habitaciones VALUES ('08','03');
INSERT INTO habitaciones VALUES ('09','02');
INSERT INTO habitaciones VALUES ('10','01');
INSERT INTO habitaciones VALUES ('11','03');


---Personas -- nif, nombre, apellidos, direccion, localidad
INSERT INTO personas VALUES ('54890865P','Alvaro','Rodriguez Marquez','C\ Alemania nº19','Madrid (Madrid)');
INSERT INTO personas VALUES ('40687067K','Aitor','Leon Delgado','Ciudad Blanca Blq 16 1º-D','Adanero (Ávila)');
INSERT INTO personas VALUES ('77399071T','Virginia','Leon Delgado','Ciudad Blanca Blq 16 1º-D','Muñopepe (Ávila)');
INSERT INTO personas VALUES ('69191424H','Antonio Agustin','Fernandez Melendez','C\Armero nº 19','Muñico (Ávila)');
INSERT INTO personas VALUES ('36059752F','Antonio','Melendez Delgado','C\Armero nº 18','Navadijos (Ávila)');
INSERT INTO personas VALUES ('10402498N','Carlos','Mejias Calatrava','C\ Francisco de Rioja nº 9','Abusejo (Salamanca)');
INSERT INTO personas VALUES ('10950967T','Ana','Gutierrez Bando','C\ Burgos nº 3','Alaraz (Salamanca)');
INSERT INTO personas VALUES ('88095695Z','Adrian','Garcia Guerra','C\ Nueva nº 14','Mozárbez (Salamanca)');
INSERT INTO personas VALUES ('95327640T','Juan Carlos','Romero Diaz','C\ San Lorenzo nº 22','Ajalvir (Madrid)');
INSERT INTO personas VALUES ('06852683V','Francisco','Franco Giraldez','AAVV Rosales nº 1','Leganés (Madrid)');


---Estancias -- codigo, fecha inicio, fecha fin, numerohabitacion, nifresponsable, nifcliente, codigoregimen
INSERT INTO estancias VALUES ('00',to_DATE('11-03-2016 12:00','DD-MM-YYYY hh24:mi'),to_DATE('13-03-2016 12:00','DD-MM-YYYY hh24:mi'),'00','54890865P','54890865P','AD');
INSERT INTO estancias VALUES ('01',to_DATE('19-05-2015 17:00','DD-MM-YYYY hh24:mi'),to_DATE('25-05-2015 17:00','DD-MM-YYYY hh24:mi'),'10','10950967T','10950967T','MP');
INSERT INTO estancias VALUES ('02',to_DATE('20-09-2015 13:30','DD-MM-YYYY hh24:mi'),to_DATE('21-09-2015 13:30','DD-MM-YYYY hh24:mi'),'03','10402498N','10402498N','AD');
INSERT INTO estancias VALUES ('03',to_DATE('14-03-2015 11:15','DD-MM-YYYY hh24:mi'),to_DATE('16-03-2015 11:15','DD-MM-YYYY hh24:mi'),'02','95327640T','95327640T','MP');
INSERT INTO estancias VALUES ('04',to_DATE('30-07-2015 18:00','DD-MM-YYYY hh24:mi'),to_DATE('11-08-2015 18:00','DD-MM-YYYY hh24:mi'),'09','06852683V','06852683V','TI');
INSERT INTO estancias VALUES ('05',to_DATE('09-01-2016 16:35','DD-MM-YYYY hh24:mi'),to_DATE('12-01-2015 16:35','DD-MM-YYYY hh24:mi'),'05','40687067K','40687067K','MP');
INSERT INTO estancias VALUES ('06',to_DATE('26-12-2015 19:50','DD-MM-YYYY hh24:mi'),to_DATE('01-01-2016 19:50','DD-MM-YYYY hh24:mi'),'07','77399071T','77399071T','PC');
INSERT INTO estancias VALUES ('07',to_DATE('22-02-2016 20:20','DD-MM-YYYY hh24:mi'),to_DATE('29-02-2016 20:20','DD-MM-YYYY hh24:mi'),'04','69191424H','69191424H','PC');


---Facturas -- numero, codigoestancia, fecha
INSERT INTO facturas VALUES ('00','00',to_DATE('13-03-2016 12:00','DD-MM-YYYY hh24:mi'));
INSERT INTO facturas VALUES ('01','02',to_DATE('21-09-2015 13:30','DD-MM-YYYY hh24:mi'));
INSERT INTO facturas VALUES ('02','04',to_DATE('11-08-2015 18:00','DD-MM-YYYY hh24:mi'));
INSERT INTO facturas VALUES ('03','07',to_DATE('29-02-2016 20:20','DD-MM-YYYY hh24:mi'));
INSERT INTO facturas VALUES ('04','05',to_DATE('12-01-2015 16:35','DD-MM-YYYY hh24:mi'));
INSERT INTO facturas VALUES ('05','01',to_DATE('25-05-2015 17:00','DD-MM-YYYY hh24:mi'));


---Gastos Extras -- codigogasto, codigoestancia, fecha, concepto, cuantia
INSERT INTO gastos_extra VALUES ('00','03',to_DATE('15-03-2015 18:23','DD-MM-YYYY hh24:mi'),'Bolos',7);
INSERT INTO gastos_extra VALUES ('01','02',to_DATE('20-09-2015 19:15','DD-MM-YYYY hh24:mi'),'Centro de pasatiempo de mascotas',12);
INSERT INTO gastos_extra VALUES ('02','01',to_DATE('23-05-2015 12:40','DD-MM-YYYY hh24:mi'),'Piscina privada',2);
INSERT INTO gastos_extra VALUES ('03','01',to_DATE('23-05-2015 17:50','DD-MM-YYYY hh24:mi'),'Wifi',2);
INSERT INTO gastos_extra VALUES ('04','03',to_DATE('15-03-2015 20:00','DD-MM-YYYY hh24:mi'),'Masajes',8);
INSERT INTO gastos_extra VALUES ('05','05',to_DATE('11-01-2016 16:00','DD-MM-YYYY hh24:mi'),'Spa',8);
INSERT INTO gastos_extra VALUES ('06','07',to_DATE('24-02-2016 16:45','DD-MM-YYYY hh24:mi'),'Alquiler de bicicletas',5);
INSERT INTO gastos_extra VALUES ('07','02',to_DATE('20-09-2015 16:00','DD-MM-YYYY hh24:mi'),'Television',2);
INSERT INTO gastos_extra VALUES ('08','04',to_DATE('02-08-2015 13:30','DD-MM-YYYY hh24:mi'),'Rellenar minibar', 15);
INSERT INTO gastos_extra VALUES ('09','00',to_DATE('12-03-2016 18:15','DD-MM-YYYY hh24:mi'),'Aire acondicionado', 6);
INSERT INTO gastos_extra VALUES ('10','06',to_DATE('28-12-2015 19:23','DD-MM-YYYY hh24:mi'),'Telefono',3);
INSERT INTO gastos_extra VALUES ('11','02',to_DATE('21-09-2015 10:00','DD-MM-YYYY hh24:mi'),'Alquiler de pistas',2);


---Actividades -- codigo, nombre, descripcion, precioporpersona, comisionhotel, costepersonaparahotel
INSERT INTO actividades VALUES ('A001','Aventura','Red de cuevas naturales visitables-Barrancos',15,3.74,0);
INSERT INTO actividades VALUES ('C093','Curso','Espeleologia- iniciacion',75,13,10);
INSERT INTO actividades VALUES ('B302','Hipica','Montar a caballo durante 2 horas',22,4,5);
INSERT INTO actividades VALUES ('A032','Tiro con Arco','4?u desperfecto de flecha',12,2,4);


---Actividadesrealizadas -- codigoestancia, codigoactividad, fecha, numpersonas, abonado
INSERT INTO actividadesrealizadas VALUES ('01','A001',to_DATE('20-05-2015 17:30','DD-MM-YYYY hh24:mi'),2,'S');
INSERT INTO actividadesrealizadas VALUES ('07','C093',to_DATE('25-02-2016 18:00','DD-MM-YYYY hh24:mi'),5,'N');
INSERT INTO actividadesrealizadas VALUES ('06','B302',to_DATE('29-12-2015 12:00','DD-MM-YYYY hh24:mi'),1,'N');
INSERT INTO actividadesrealizadas VALUES ('04','A032',to_DATE('04-08-2015 11:30','DD-MM-YYYY hh24:mi'),2,'S');
INSERT INTO actividadesrealizadas VALUES ('01','C093',to_DATE('21-05-2015 17:00','DD-MM-YYYY hh24:mi'),2,'N');
INSERT INTO actividadesrealizadas VALUES ('05','A001',to_DATE('10-01-2016 16:15','DD-MM-YYYY hh24:mi'),4,'S');
INSERT INTO actividadesrealizadas VALUES ('07','B302',to_DATE('28-02-2016 17:45','DD-MM-YYYY hh24:mi'),3,'N');
INSERT INTO actividadesrealizadas VALUES ('04','A032',to_DATE('07-08-2015 12:15','DD-MM-YYYY hh24:mi'),6,'S');

---Modificacion de tabla necesaria para procedimiento 5
ALTER TABLE ActividadesRealizadas
ADD balancehotel NUMBER(6,2);
