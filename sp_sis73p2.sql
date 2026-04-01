-- Informaci¢n: para Panam  Presentar los datos en el Grid
-- Creado     : 11/09/2007 - Autor: Ruben Arnaez 

-- DROP PROCEDURE sp_sisra;

create procedure "informix".sp_sisra(
a_cod_errado	char(10), 
a_cod_correcto 	char(10),
a_user			char(8)
) returning integer,
            char(100);

define _tiempo	datetime year to fraction(5);
define _error	integer;
let _tiempo = current;


-- Para cargar la tabla temporal de Clientes
define ccod_cliente          char(10);
define ccod_compania         char(3);
define ccod_sucursal         char(3),
define ccod_origen           char(3);
define ccod_grupo            char(5);
define ccod_clasehosp        char(3);
define ccod_espmedica        char(3);
define ccod_ocupacion        char(3);
define ccod_trabajo          char(3);
define ccod_actividad        char(3);
define ccode_pais            char(3);
define ccode_provincia       char(2);
define ccode_ciudad          char(2);
define ccode_distrito        char(2);
define ccode_correg          char(5);
define cnombre               varchar(100);
define cnombre_razon         varchar(100);
define cdireccion_1          varchar(50);
define cdireccion_2          varchar(50);
define capartado             char(20);
define ctipo_persona         char(1);
define cactual_potencial     char(1);
define ccedula               varchar(30);
define ctelefono1            char(10);
define ctelefono2            char(10);
define ce_mail               char(50);
define cfax                  char(10);
define cdate_added           date;
define cuser_added           char(8);
define cde_la_red            smallint;
define cmala_referencia      smallint;
define cdesc_mala_ref        varchar(250);
define cfecha_aniversario    date;
define csexo                 char(1);
define cdigito_ver           char(2);
define cdate_changed         date;
define cuser_changed         char(8);
define cnombre_original      char(100);
define cced_provincia        char(2);
define cced_inicial          char(2);
define cced_tomo             char(6);
define cced_folio            char(6);
define cced_asiento          char(6);
define caseg_primer_nom      char(100);
define caseg_segundo_nom     char(40);
define caseg_primer_ape      char(40);
define caseg_segundo_ape     char(40);
define caseg_casada_ape      char(40);
define cced_correcta         smallint;
define cpasaporte            smallint;
define ccotizacion           char(10);
define cde_cotizacion        smallint;
define ccelular              char(10);
define cdia_cobros1          integer;
define cdia_cobros2          integer;
define ccontacto             char(50);
define ctelefono3            char(10);
define cdireccion_cob        varchar(100);
define ces_taller            smallint;
define cproveedor_autoriza   smallint;
define cip_number            char(30);
define cno_beeper            char(10);
define ccod_beeper           char(3);
define cperiodo_pago         smallint;
define ctipo_cuenta          char(1);
define ccod_cuenta           char(17);
define ccod_banco            char(3);
define ctipo_pago            smallint;
define ccod_ruta             char(2);
define cfecha_contratacion   date;
define cfecha_cancelacion    date;
define cconsultorio_numero   integer;
define cpiso_numero          integer;
define ccosultorio_tel       char(10);
define cconsultorio_fax      char(10);
define cdias_atencion        char(20);
define chorario_atencion_d   datetime hour to fraction(5);
define chorario_atencion_a   datetime hour to fraction(5);
define cconsultorio_numero   integer;
define cpiso_numero2         integer;
define cconsultorio_tel2     char(10);
define cconsultorio_fax2     char(10);
define cdias_atencion2       char(20);
define chorario_atencion_d   datetime hour to fraction(5);
define chorario_atencion_a   datetime hour to fraction(5);
define cuniversidad          varchar(60);
define cfecha_graduacion     date;
define cpais                 varchar(20);
define cciudad               varchar(20);
define chospital_residenci   varchar(60);
define cfecha_residencia_d   date;
define cfecha_residencia_h   date;
define cpais_residencia      varchar(20);
define cciudad_residencia    varchar(20);
define ccliente_web          smallint;
define creset_password       smallint;
define cpassword_web         char(30);
define cconsultorio_1        char(10);
define cconsultorio_2        char(10);
	  
DEFINE _usuario       char(8);  -- 1
DEFINE _descripcion   char(30); -- 2
DEFINE _e_mail        char(30); -- 3 
DEFINE _status        char(1);  -- 4
DEFINE _windows_user  char(20); -- 5
DEFINE _fvac_out      date;	    -- 6
DEFINE _fvac_duein    date;	    -- 7

SET ISOLATION TO DIRTY READ;

CREATE TEMP TABLE tmp_cliclien(
cod_cliente          char(10),
cod_compania         char(3),
cod_sucursal         char(3),
cod_origen           char(3),
cod_grupo            char(5),
cod_clasehosp        char(3),
cod_espmedica        char(3),
cod_ocupacion        char(3),
cod_trabajo          char(3),
cod_actividad        char(3),
code_pais            char(3),
code_provincia       char(2),
code_ciudad          char(2),
code_distrito        char(2),
code_correg          char(5),
nombre               varchar(100),
nombre_razon         varchar(100),
direccion_1          varchar(50),
direccion_2          varchar(50),
apartado             char(20),
tipo_persona         char(1),
actual_potencial     char(1),
cedula               varchar(30),
telefono1            char(10),
telefono2            char(10),
e_mail               char(50),
fax                  char(10),
date_added           date,
user_added           char(8),
de_la_red            smallint,
mala_referencia      smallint,
desc_mala_ref        varchar(250),
fecha_aniversario    date,
sexo                 char(1),
digito_ver           char(2),
date_changed         date,
user_changed         char(8),
nombre_original      char(100),
ced_provincia        char(2),
ced_inicial          char(2),
ced_tomo             char(6),
ced_folio            char(6),
ced_asiento          char(6),
aseg_primer_nom      char(100),
aseg_segundo_nom     char(40),
aseg_primer_ape      char(40),
aseg_segundo_ape     char(40),
aseg_casada_ape      char(40),
ced_correcta         smallint,
pasaporte            smallint,
cotizacion           char(10),
de_cotizacion        smallint,
celular              char(10),
dia_cobros1          integer,
dia_cobros2          integer,
contacto             char(50),
telefono3            char(10),
direccion_cob        varchar(100),
es_taller            smallint,
proveedor_autoriza   smallint,
ip_number            char(30),
no_beeper            char(10),
cod_beeper           char(3),
periodo_pago         smallint,
tipo_cuenta          char(1),
cod_cuenta           char(17),
cod_banco            char(3),
tipo_pago            smallint,
cod_ruta             char(2),
fecha_contratacion   date,
fecha_cancelacion    date,
consultorio_numero   integer,
piso_numero          integer,
cosultorio_tel       char(10),
consultorio_fax      char(10),
dias_atencion        char(20),
horario_atencion_d   datetime hour to fraction(5),
horario_atencion_a   datetime hour to fraction(5),
consultorio_numero   integer,
piso_numero2         integer,
consultorio_tel2     char(10),
consultorio_fax2     char(10),
dias_atencion2       char(20),
horario_atencion_d   datetime hour to fraction(5),
horario_atencion_a   datetime hour to fraction(5),
universidad          varchar(60),
fecha_graduacion     date,
pais                 varchar(20),
ciudad               varchar(20),
hospital_residenci   varchar(60),
fecha_residencia_d   date,
fecha_residencia_h   date,
pais_residencia      varchar(20),
ciudad_residencia    varchar(20),
cliente_web          smallint,
reset_password       smallint,
password_web         char(30),
consultorio_1        char(10),
consultorio_2        char(10),
PRIMARY KEY		(cod_cliente)
	) WITH NO LOG;


-- Seleccionamos todas las polizas que se renuevan del ramo de Salud
foreach 
		select * 
		from cliclien 
		-- where cod_cliente = a_cod_errado
		into temp temp_cliclien;



		--insert into caspoliza
		--select * from tmp_hijo;
return 0, "Actualizacion Exitosa";
				 
			   	{return  _usuario,	   		-- 1. Usuario 
			   			_descripcion,	   	-- 2. Nombre completo del usuario
						_e_mail,     		-- 3. Correo del usuario 
						_status,	   	    -- 4. Estado del usuario 
						_windows_user,		-- 5. Usuario de windows
						_fvac_out,			-- 6. Fecha inicial de vacaciones 
						_fvac_duein	     	-- 7. fecha de regreso de Vacaciones 
				 }		
	 -- with resume;
  
  end foreach;

 end procedure;
