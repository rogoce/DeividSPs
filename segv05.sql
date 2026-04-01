create table insapli (
aplicacion           CHAR(3)                        not null,
version              CHAR(2)                        not null,
path_aplicacion      CHAR(30)                       not null,
fecha_status         DATE                           not null,
descripcion          CHAR(30)                       not null,
status               CHAR(1)                        not null,
fecha_cambio         DATE                           not null,
usuario_cambio       CHAR(8)                        not null,
primary key (aplicacion, version)
);

create table insauto (
tipo_autoriza        CHAR(2)                        not null,
aplicacion           CHAR(3)                        not null,
version              CHAR(2)                        not null,
descripcion          CHAR(30)                       not null,
primary key (tipo_autoriza, aplicacion, version),
foreign key (aplicacion, version)
      references insapli (aplicacion, version)
);

create table inscias (
codigo_compania      CHAR(3)                        not null,
descr_compania       CHAR(50)                       not null,
direccion            CHAR(70),
id_tributaria        CHAR(20),
primary key (codigo_compania)
);

create table inscone (
tipo_conexion        CHAR(10)                       not null,
descripcion          CHAR(30)                       not null,
primary key (tipo_conexion)
);

create table inserror (
tipo_error           SMALLINT                       not null,
code_error           INTEGER                        not null,
descripcion          VARCHAR(150)                   not null,
primary key (tipo_error, code_error)
);

create table inshtml (
programa             CHAR(40)                       not null,
campo                CHAR(18),
direccion            CHAR(70),
primary key (programa)
);

create table insidio (
code_idioma          CHAR(2)                        not null,
descripcion          CHAR(30)                       not null,
primary key (code_idioma)
);

create table inslabe (
label                CHAR(15)                       not null,
descripcion          CHAR(30)                       not null,
primary key (label)
);

create table inslaid (
code_idioma          CHAR(2)                        not null,
label                CHAR(15)                       not null,
valor_label          CHAR(50)                       not null,
primary key (code_idioma, label),
foreign key (code_idioma)
      references insidio (code_idioma),
foreign key (label)
      references inslabe (label)
);

create table insmenu (
codigo_programa      CHAR(40)                       not null,
descripcion          CHAR(30)                       not null,
status               CHAR(1)                        not null,
fecha_status         DATE                           not null,
primary key (codigo_programa)
);

create table insmeop (
codigo_programa      CHAR(40)                       not null,
secuencia_opcion     CHAR(40)                       not null,
fila                 SMALLINT                       not null,
columna              SMALLINT                       not null,
descripcion          CHAR(30)                       not null,
status               CHAR(1)                        not null,
fecha_status         DATE                           not null,
primary key (codigo_programa, secuencia_opcion),
foreign key (codigo_programa)
      references insmenu (codigo_programa)
);

create table inspara (
codigo_parametro     CHAR(18)                       not null,
descripcion          CHAR(30)                       not null,
aplicacion           CHAR(3)                        not null,
version              CHAR(2)                        not null,
tipo_parametro       CHAR(1)                        not null,
primary key (codigo_parametro, aplicacion, version),
foreign key (aplicacion, version)
      references insapli (aplicacion, version)
);

create table inspddw (
nombre_data_window   CHAR(50),
descripcion          CHAR(60),
ancho_ventana        INTEGER,
alto_ventana         INTEGER,
ancho_data_window    INTEGER,
alto_data_window     INTEGER,
x_dw                 INTEGER,
y_dw                 INTEGER
);

create table inspefi (
codigo_perfil        CHAR(3)                        not null,
descripcion          CHAR(30),
primary key (codigo_perfil)
);

create table insplan (
cliente              CHAR(6),
usuario              CHAR(8),
password             CHAR(8),
basedato             CHAR(18),
proveedor            CHAR(15),
servidor             CHAR(22),
autocommit           CHAR(11),
parametros           CHAR(72),
scanner              CHAR(1),
telecheck            CHAR(1),
compania             CHAR(3),
agencia              CHAR(3),
rutas                CHAR(3),
fecha                DATE
);

create table insprin (
code_printer         CHAR(3)                        not null,
dispositivo          CHAR(50)                       not null,
descripcion          CHAR(30)                       not null,
status               CHAR(1)                        not null,
fecha_status         DATE,
primary key (code_printer)
);

create table insprog (
codigo_programa      CHAR(40)                       not null,
tipo_programa        CHAR(2)                        not null,
aplicacion           CHAR(3)                        not null,
version              CHAR(2)                        not null,
descripcion          CHAR(40)                       not null,
status               CHAR(1)                        not null,
fecha_status         DATE                           not null,
comando_ejecucion    CHAR(30)                       not null,
opcion_del_menu      CHAR(40),
primary key (codigo_programa),
foreign key (aplicacion, version)
      references insapli (aplicacion, version)
);

create table insserv (
servidor             CHAR(20)                       not null,
tipo_conexion        CHAR(10),
descripcion          CHAR(30)                       not null,
ip_adress            CHAR(20)                       not null,
hostname             CHAR(20)                       not null,
web_server           CHAR(20),
servicio             CHAR(15),
primary key (servidor),
foreign key (tipo_conexion)
      references inscone (tipo_conexion)
);

create table instibd (
tipo_base_dato       CHAR(4)                        not null,
descripcion          CHAR(30)                       not null,
primary key (tipo_base_dato)
);

create table insuser (
usuario              CHAR(8)                        not null,
fecha_inicio         DATE                           not null,
dias_password        SMALLINT,
hora_inicio          DATETIME YEAR TO FRACTION (5) not null,
hora_final           DATETIME YEAR TO FRACTION (5) not null,
ultimo_login         DATE,
no_login_permitido   SMALLINT                       not null,
ult_cbio_password    DATE,
codigo_perfil        CHAR(3),
descripcion          CHAR(30),
password             CHAR(10),
e_mail               CHAR(30),
fecha_final          DATE,
status               CHAR(1),
fecha_status         DATE,
fecha_cambio         DATE,
code_idioma          CHAR(2),
codigo_menu          CHAR(40),
nivel                CHAR(2),
crear_cliente        SMALLINT                       not null,
aut_endoso           SMALLINT                       not null,
windows_user         CHAR(20),
supervisor_ren       SMALLINT,
primary key (usuario),
foreign key (code_idioma)
      references insidio (code_idioma),
foreign key (codigo_perfil)
      references inspefi (codigo_perfil)
);

create  index idx_insuser04 on insuser (
windows_user ASC
);

create table insvaut (
aplicacion           CHAR(3)                        not null,
version              CHAR(2)                        not null,
tipo_autorizacion    CHAR(2)                        not null,
valor                CHAR(6)                        not null,
primary key (aplicacion, version, tipo_autorizacion)
);

create table pbcatcol (
pbc_tnam             CHAR(19)                       not null,
pbc_tid              INTEGER,
pbc_ownr             CHAR(9)                        not null,
pbc_cnam             CHAR(19)                       not null,
pbc_cid              SMALLINT,
pbc_labl             VARCHAR(254),
pbc_lpos             SMALLINT,
pbc_hdr              VARCHAR(254),
pbc_hpos             SMALLINT,
pbc_jtfy             SMALLINT,
pbc_mask             VARCHAR(31),
pbc_case             SMALLINT,
pbc_hght             SMALLINT,
pbc_wdth             SMALLINT,
pbc_ptrn             VARCHAR(31),
pbc_bmap             CHAR(1),
pbc_init             VARCHAR(254),
pbc_cmnt             VARCHAR(254),
pbc_edit             VARCHAR(31),
pbc_tag              VARCHAR(254)
);

create unique index pbcatc_x on pbcatcol (
pbc_tnam ASC,
pbc_ownr ASC,
pbc_cnam ASC
);

create table pbcatedt (
pbe_name             VARCHAR(30)                    not null,
pbe_edit             VARCHAR(254),
pbe_type             SMALLINT,
pbe_cntr             INTEGER,
pbe_seqn             SMALLINT                       not null,
pbe_flag             INTEGER,
pbe_work             CHAR(32)
);

create unique index pbcate_x on pbcatedt (
pbe_name ASC,
pbe_seqn ASC
);

create table pbcatfmt (
pbf_name             VARCHAR(30)                    not null,
pbf_frmt             VARCHAR(254),
pbf_type             SMALLINT,
pbf_cntr             INTEGER
);

create unique index pbcatf_x on pbcatfmt (
pbf_name ASC
);

create table pbcattbl (
pbt_tnam             CHAR(19)                       not null,
pbt_tid              INTEGER,
pbt_ownr             CHAR(9)                        not null,
pbd_fhgt             SMALLINT,
pbd_fwgt             SMALLINT,
pbd_fitl             CHAR(1),
pbd_funl             CHAR(1),
pbd_fchr             SMALLINT,
pbd_fptc             SMALLINT,
pbd_ffce             CHAR(18),
pbh_fhgt             SMALLINT,
pbh_fwgt             SMALLINT,
pbh_fitl             CHAR(1),
pbh_funl             CHAR(1),
pbh_fchr             SMALLINT,
pbh_fptc             SMALLINT,
pbh_ffce             CHAR(18),
pbl_fhgt             SMALLINT,
pbl_fwgt             SMALLINT,
pbl_fitl             CHAR(1),
pbl_funl             CHAR(1),
pbl_fchr             SMALLINT,
pbl_fptc             SMALLINT,
pbl_ffce             CHAR(18),
pbt_cmnt             VARCHAR(254)
);

create unique index pbcatt_x on pbcattbl (
pbt_tnam ASC,
pbt_ownr ASC
);

create table pbcatvld (
pbv_name             VARCHAR(30)                    not null,
pbv_vald             VARCHAR(254),
pbv_type             SMALLINT,
pbv_cntr             INTEGER,
pbv_msg              VARCHAR(254)
);

create unique index pbcatv_x on pbcatvld (
pbv_name ASC
);

create table inslabs (
programa             CHAR(40),
no_linea             SMALLINT,
secuencia            SMALLINT,
label                CHAR(50)                       not null,
pos_inicial          SMALLINT,
sts_actual           CHAR(1)                        not null,
fecha_sts            DATE,
usuario              CHAR(8)                        not null,
primary key (programa, no_linea, secuencia),
foreign key (programa)
      references insprog (codigo_programa)
);

create table insprxu (
code_printer         CHAR(3)                        not null,
usuario              CHAR(8)                        not null,
tipo_printer         CHAR(1)                        not null,
tipo_impresion       SMALLINT,
primary key (code_printer, usuario),
foreign key (code_printer)
      references insprin (code_printer),
foreign key (usuario)
      references insuser (usuario)
);

create table insdber (
tipo_base_dato       CHAR(4)                        not null,
numero_dberror       INTEGER                        not null,
code_error           INTEGER                        not null,
tipo_error           SMALLINT                       not null,
primary key (tipo_base_dato, numero_dberror),
foreign key (tipo_error, code_error)
      references inserror (tipo_error, code_error),
foreign key (tipo_base_dato)
      references instibd (tipo_base_dato)
);

create table insbdat (
base_dato            CHAR(18)                       not null,
servidor             CHAR(20)                       not null,
tipo_base_dato       CHAR(4),
descripcion          CHAR(30)                       not null,
primary key (base_dato, servidor),
foreign key (servidor)
      references insserv (servidor),
foreign key (tipo_base_dato)
      references instibd (tipo_base_dato)
);

create table insmep1 (
programa_opcion      CHAR(40)                       not null,
secuencia_opcion     CHAR(40)                       not null,
codigo_programa      CHAR(40)                       not null,
programa_opcion1     CHAR(40)                       not null,
secuencia_opcion1    CHAR(40)                       not null,
status               CHAR(1)                        not null,
fecha_status         DATE                           not null,
primary key (codigo_programa, secuencia_opcion, programa_opcion, programa_opcion1),
foreign key (codigo_programa)
      references insprog (codigo_programa)
);

create table insmepr (
programa_opcion      CHAR(40)                       not null,
secuencia_opcion     CHAR(40)                       not null,
codigo_programa      CHAR(40)                       not null,
secuencia            CHAR(40),
status               CHAR(1),
fecha_status         DATE,
primary key (programa_opcion, secuencia_opcion, codigo_programa),
foreign key (codigo_programa)
      references insprog (codigo_programa),
foreign key (programa_opcion)
      references insprog (codigo_programa)
);

create table inspapl (
codigo_perfil        CHAR(3)                        not null,
aplicacion           CHAR(3)                        not null,
version              CHAR(2)                        not null,
autoriza_total       CHAR(1)                        not null,
adicion              CHAR(1)                        not null,
modificar            CHAR(1)                        not null,
eliminar             CHAR(1)                        not null,
status               CHAR(1)                        not null,
fecha_status         DATE                           not null,
primary key (codigo_perfil, aplicacion, version),
foreign key (aplicacion, version)
      references insapli (aplicacion, version),
foreign key (codigo_perfil)
      references inspefi (codigo_perfil)
);

create table inspexe (
codigo_programa      CHAR(40)                       not null,
codigo_perfil        CHAR(3)                        not null,
aplicacion           CHAR(3)                        not null,
version              CHAR(2)                        not null,
adicion              CHAR(1),
modificar            CHAR(1),
eliminar             CHAR(1),
status               CHAR(1),
fecha_status         DATE,
primary key (codigo_programa, codigo_perfil, aplicacion, version),
foreign key (codigo_perfil, aplicacion, version)
      references inspapl (codigo_perfil, aplicacion, version),
foreign key (codigo_programa)
      references insprog (codigo_programa)
);

create table insagen (
codigo_agencia       CHAR(3)                        not null,
codigo_compania      CHAR(3)                        not null,
servidor             CHAR(20),
base_dato            CHAR(18),
descripcion          CHAR(30)                       not null,
jefe_agencia         CHAR(30)                       not null,
e_mail               CHAR(30),
telefono             CHAR(15)                       not null,
modo                 CHAR(1),
la_criptas           BYTE,
centro_costo         CHAR(3),
banco_tarjeta        CHAR(3),
banco_caja           CHAR(3),
primary key (codigo_agencia, codigo_compania),
foreign key (base_dato, servidor)
      references insbdat (base_dato, servidor),
foreign key (codigo_compania)
      references inscias (codigo_compania),
foreign key (servidor)
      references insserv (servidor)
);

create table inscapl (
codigo_compania      CHAR(3)                        not null,
codigo_agencia       CHAR(3)                        not null,
aplicacion           CHAR(3)                        not null,
version              CHAR(2)                        not null,
fase_instalacion     CHAR(1)                        not null,
status               CHAR(1)                        not null,
fecha_status         DATE                           not null,
primary key (codigo_compania, codigo_agencia, aplicacion, version),
foreign key (codigo_agencia, codigo_compania)
      references insagen (codigo_agencia, codigo_compania),
foreign key (aplicacion, version)
      references insapli (aplicacion, version),
foreign key (codigo_compania)
      references inscias (codigo_compania)
);

create table inspaag (
codigo_compania      CHAR(3)                        not null,
codigo_agencia       CHAR(3)                        not null,
aplicacion           CHAR(3)                        not null,
version              CHAR(2)                        not null,
codigo_parametro     CHAR(18)                       not null,
valor_parametro      CHAR(20)                       not null,
primary key (codigo_compania, codigo_agencia, aplicacion, version, codigo_parametro),
foreign key (codigo_compania, codigo_agencia, aplicacion, version)
      references inscapl (codigo_compania, codigo_agencia, aplicacion, version),
foreign key (codigo_parametro, aplicacion, version)
      references inspara (codigo_parametro, aplicacion, version)
);

create table insauca (
codigo_compania      CHAR(3)                        not null,
codigo_agencia       CHAR(3)                        not null,
usuario              CHAR(8)                        not null,
aplicacion           CHAR(3)                        not null,
version              CHAR(2)                        not null,
tipo_autorizacion    CHAR(2)                        not null,
rango_inicio         DECIMAL(16,2)                  not null,
rango_final          DECIMAL(16,2),
status               CHAR(1)                        not null,
fecha_status         DATE,
primary key (codigo_compania, codigo_agencia, usuario, aplicacion, version, tipo_autorizacion),
foreign key (codigo_agencia, codigo_compania)
      references insagen (codigo_agencia, codigo_compania),
foreign key (aplicacion, version)
      references insapli (aplicacion, version),
foreign key (codigo_compania, codigo_agencia, aplicacion, version)
      references inscapl (codigo_compania, codigo_agencia, aplicacion, version),
foreign key (codigo_compania)
      references inscias (codigo_compania),
foreign key (usuario)
      references insuser (usuario)
);

create table insusco (
usuario              CHAR(8)                        not null,
codigo_compania      CHAR(3)                        not null,
codigo_agencia       CHAR(3)                        not null,
password             CHAR(10)                       not null,
status               CHAR(1)                        not null,
fecha_status         DATE                           not null,
primary key (usuario, codigo_compania, codigo_agencia),
foreign key (codigo_agencia, codigo_compania)
      references insagen (codigo_agencia, codigo_compania),
foreign key (usuario)
      references insuser (usuario)
);

create table insinpr (
codigo_compania      CHAR(3)                        not null,
codigo_agencia       CHAR(3)                        not null,
reporte              CHAR(15)                       not null,
code_printer         CHAR(3)                        not null,
primary key (codigo_compania, codigo_agencia, reporte, code_printer),
foreign key (codigo_agencia, codigo_compania)
      references insagen (codigo_agencia, codigo_compania),
foreign key (code_printer)
      references insprin (code_printer)
);

create table insexap (
usuario              CHAR(8)                        not null,
codigo_compania      CHAR(3)                        not null,
codigo_agencia       CHAR(3)                        not null,
aplicacion           CHAR(3)                        not null,
version              CHAR(2)                        not null,
excepcion_total      CHAR(1),
primary key (usuario, codigo_compania, codigo_agencia, aplicacion, version),
foreign key (codigo_compania, codigo_agencia, aplicacion, version)
      references inscapl (codigo_compania, codigo_agencia, aplicacion, version),
foreign key (usuario, codigo_compania, codigo_agencia)
      references insusco (usuario, codigo_compania, codigo_agencia),
foreign key (usuario)
      references insuser (usuario)
);

create table insexpr (
codigo_compania      CHAR(3)                        not null,
codigo_agencia       CHAR(3)                        not null,
aplicacion           CHAR(3)                        not null,
version              CHAR(2)                        not null,
codigo_programa      CHAR(40)                       not null,
usuario              CHAR(8)                        not null,
adicion              CHAR(1),
modificar            CHAR(1),
eliminar             CHAR(1),
status               CHAR(1),
fecha_sts            DATE,
primary key (codigo_compania, codigo_agencia, aplicacion, version, codigo_programa, usuario),
foreign key (usuario, codigo_compania, codigo_agencia, aplicacion, version)
      references insexap (usuario, codigo_compania, codigo_agencia, aplicacion, version),
foreign key (codigo_programa)
      references insprog (codigo_programa),
foreign key (usuario, codigo_compania, codigo_agencia)
      references insusco (usuario, codigo_compania, codigo_agencia),
foreign key (usuario)
      references insuser (usuario)
);

create table inslogi (
codigo_compania      CHAR(3)                        not null,
codigo_agencia       CHAR(3)                        not null,
usuario              CHAR(8)                        not null,
no_tarea             SMALLINT                       not null,
fecha_login          DATE                           not null,
maneja_perfiles      CHAR(1)                        not null,
primary key (codigo_compania, codigo_agencia, usuario, no_tarea),
foreign key (codigo_agencia, codigo_compania)
      references insagen (codigo_agencia, codigo_compania),
foreign key (usuario, codigo_compania, codigo_agencia)
      references insusco (usuario, codigo_compania, codigo_agencia),
foreign key (usuario)
      references insuser (usuario)
);

