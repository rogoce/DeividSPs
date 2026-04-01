-- WorkFlow - Busqueda por Asegurado

-- Creado    : 11/03/2004 - Autor: Amado Perez  
-- Modificado: 24/03/2004 - Autor: Demetrio Hurtado Almanza
-- Modificado: 12/04/2004 - Autor: Demetrio Hurtado Almanza
			   -- Se agregaron a la salida el user_windows, user_deivid, no_reclamo
			    
drop procedure sp_rwf171;

create procedure "informix".sp_rwf171(a_placa char(10) ,a_fecha_siniestro char(10), a_no_documento char(20))
returning char(20) as numrecla,
          date as fecha_siniestro,
		  date as fecha_tramite,
		  date as fecha_reclamo,
		  char(20) as no_documento,
		  char(5) as no_unidad,
		  char(10) as no_tramite,
		  char(50) as nombre_ajustador,
		  char(100) as nombre_asegurado,
		  char(100) as nombre_conductor,
		  varchar(40) as user_windows,
		  char(8) as user_deivid,
		  char(10) as no_reclamo,
		  varchar(30) as e_mail,
		  integer as estatus_audiencia,
		  datetime hour to second as hora_siniestro,
		  char(10) as placa,
		  varchar(30) as cedula;
		  
define _no_reclamo 			char(10);
define _numrecla   			char(20);
define _fecha_siniestro		date;
define _fecha_tramite      	date;
define _fecha_reclamo      	date;
define _no_documento		char(20);
define _no_unidad			char(5);
define _no_tramite			char(10);
define _cod_ajustador      	char(10);
define _cod_asegurado      	char(10);
define _cod_conductor      	char(10);
define _nombre_asegurado   	char(100);
define _nombre_ajustador  	char(100);
define _nombre_conductor  	char(100);
define _fecha				date;
define _user_windows		varchar(40);
define _user_deivid			char(8);
define _dominio_ultimus		varchar(20);
define _e_mail              varchar(30);
define _estatus_audiencia   integer;
define _cadena              varchar(255);
define _select              varchar(255);
define _where               varchar(255);
define _cad_fecha_s         varchar(255);
define _cad_placa           varchar(255);
define _cad_doc             varchar(255);
define _hora_siniestro      datetime hour to second;
define _no_motor            char(30);
define _placa               char(10);
define _cedula              varchar(30);

if a_fecha_siniestro = "*" and a_placa = "*" and a_no_documento = "%" then
else	

create temp table tmp_filtro(
	no_reclamo	char(10)
	) with no log;

create temp table tmp_reclamo(
	numrecla        char(20),
	fecha_siniestro date,
	fecha_tramite   date,
	fecha_reclamo	date,
	no_documento	char(20),
	no_unidad		char(5),
	no_tramite		char(10),
	cod_ajustador	char(3),
	cod_asegurado   char(10),
	cod_conductor	char(10),
	no_reclamo		char(10),
	estatus_audiencia int,
	hora_siniestro  datetime hour to second,
	placa           char(10)
	) with no log;

SET ISOLATION TO DIRTY READ;

	--set debug file to "sp_rwf171.trc";
	--trace on;


 let _cadena = "";
 let _cad_fecha_s = "";
 let _cad_placa = "";
 let _cad_doc = "and a.no_documento like ? ";
 let _select = "select a.no_reclamo from recrcmae a ";
 let _where = "where a.actualizado = 1and a.numrecla[1,2] in ('02','20','23') ";

if a_fecha_siniestro <> "*" then -- Por Fecha del Siniestro
    let _fecha = date(a_fecha_siniestro);
	let _cad_fecha_s = "and a.fecha_siniestro = ? ";	
end if

if  a_placa <> "*" THEN -- Por Placa
	let _select = _select || ", emivehic b ";
	let _where = "where a.no_motor = b.no_motor and a.actualizado = 1 " ;
	let _cad_placa = "and (b.placa = ? or b.placa_taxi = ?) ";
end if

if a_no_documento <> "%" then -- Por Fecha del Siniestro
	let _cad_doc = "and a.no_documento = ? ";		
end if

PREPARE stmt_id FROM _select || _where || _cad_fecha_s || _cad_placa || _cad_doc;

DECLARE cust_cur cursor FOR stmt_id;
if  a_placa <> "*"  then
	if a_fecha_siniestro <> "*" then
		OPEN cust_cur USING _fecha, a_placa, a_placa, a_no_documento;
	else
		OPEN cust_cur USING a_placa, a_placa, a_no_documento;
	end if
else 
	if a_fecha_siniestro <> "*" then
		OPEN cust_cur USING _fecha, a_no_documento;
	else
		OPEN cust_cur USING a_no_documento;
	end if
end if

WHILE (1 = 1)

-- Fetch a row from the cursor "cust_cur" and store
-- the returned column values to the SPL variables
FETCH cust_cur INTO _no_reclamo;
-- Check if FETCH reached end-of-table (SQLCODE = 100)
-- if so, exit from while loop; else return the columns
-- and continue

IF (SQLCODE != 100) THEN

		insert into tmp_filtro
		values (_no_reclamo);
ELSE
-- break the while loop
	EXIT;
END IF

END WHILE

-- Close the cursor "cust_cur"

CLOSE cust_cur;

-- Free the resources allocated for cursor "cust_cur"

FREE cust_cur ;

-- Free the resources allocated for statement "statement_id"

FREE stmt_id ;


foreach
 select no_reclamo
   into _no_reclamo
   from tmp_filtro

	select numrecla,
	       fecha_siniestro,
		   fecha_tramite,
		   fecha_reclamo,
		   no_documento,
		   no_unidad,
		   no_tramite,
		   ajust_interno,
		   cod_asegurado,
		   cod_conductor,
		   estatus_audiencia,
		   hora_siniestro,
		   no_motor
	  into _numrecla,
	       _fecha_siniestro,
		   _fecha_tramite,
		   _fecha_reclamo,
		   _no_documento,
		   _no_unidad,
		   _no_tramite,
		   _cod_ajustador,
		   _cod_asegurado,
		   _cod_conductor,
		   _estatus_audiencia,
		   _hora_siniestro,
		   _no_motor
	  from recrcmae
	 where no_reclamo = _no_reclamo;

	select placa
	  into _placa
	  from emivehic
	 where no_motor = _no_motor;

	insert into tmp_reclamo
	values(
	_numrecla,
	_fecha_siniestro,
	_fecha_tramite,
	_fecha_reclamo,
	_no_documento,
	_no_unidad,
	_no_tramite,
	_cod_ajustador,
	_cod_asegurado,
	_cod_conductor,
	_no_reclamo,
	_estatus_audiencia,
	_hora_siniestro,
	_placa
	);

end foreach

foreach
 select numrecla,
		fecha_siniestro,
		fecha_tramite,
		fecha_reclamo,
		no_documento,
		no_unidad,
		no_tramite,
		cod_ajustador,
		cod_asegurado,
		cod_conductor,
		no_reclamo,
		estatus_audiencia,
		hora_siniestro,
		placa
   into _numrecla,
		_fecha_siniestro,
		_fecha_tramite,
		_fecha_reclamo,
		_no_documento,
		_no_unidad,
		_no_tramite,
		_cod_ajustador,
		_cod_asegurado,
		_cod_conductor,
		_no_reclamo,
		_estatus_audiencia,
		_hora_siniestro,
		_placa
   from tmp_reclamo
  order by fecha_siniestro, numrecla

	select nombre,
	       cedula
	  into _nombre_asegurado,
	       _cedula
	  from cliclien
	 where cod_cliente = _cod_asegurado;

	select nombre
	  into _nombre_conductor
	  from cliclien
	 where cod_cliente = _cod_conductor;

	select nombre,
		   usuario	
	  into _nombre_ajustador,
	       _user_deivid
	  from recajust
	 where cod_ajustador = _cod_ajustador;

	select windows_user, e_mail
	  into _user_windows, _e_mail
	  from insuser
	 where usuario = _user_deivid;

    select dominio_ultimus
	  into _dominio_ultimus
	  from parparam
	 where cod_compania = '001';

    let	_user_windows = trim(_dominio_ultimus) || trim(_user_windows);

	return _numrecla,
		   _fecha_siniestro,
		   _fecha_tramite,
		   _fecha_reclamo,
		   _no_documento,
		   _no_unidad,
		   _no_tramite,
		   _nombre_ajustador,
		   _nombre_asegurado,
		   _nombre_conductor,
		   _user_windows,
		   _user_deivid,
		   _no_reclamo,
		   _e_mail,
		   _estatus_audiencia,
		   _hora_siniestro,
		   _placa,
		   _cedula
		   with resume;

end foreach

drop table tmp_filtro;
drop table tmp_reclamo;
end if
end procedure;
