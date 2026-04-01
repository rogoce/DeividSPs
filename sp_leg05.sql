-- Conversion de registros para tabla de demandas legdeman proveniente de legdemanbk
-- Creado    : 06/08/2015 - Autor: Lic. Armando Moreno 

DROP PROCEDURE sp_leg05;
CREATE PROCEDURE "informix".sp_leg05()
RETURNING smallint;

-- Para el nuevo proceso
define _no_demanda    		char(10);
define _date_added			date;
DEFINE _demandante		  varchar(100);
DEFINE _demandado		  varchar(100);
DEFINE _numrecla		  char(18);
DEFINE _cod_asegurado     char(10);
DEFINE _cod_abogado       char(3);
DEFINE _cod_depto		  char(3);
DEFINE _juzgado           char(3);
DEFINE _estatus_actual    smallint;
DEFINE _instancia         smallint;
DEFINE _expediente        char(20);
DEFINE _pronostico   	  smallint;
DEFINE _monto_cuantia		DECIMAL(16,2);
DEFINE _tot_honorario_legal DECIMAL(16,2);
DEFINE _tot_reserva			DECIMAL(16,2);
DEFINE v_nombre_aseg		CHAR(100);
DEFINE _n_pronostico		char(15);
define _n_instancia			char(20);
define _n_estatus_actual    char(8);
define v_nombre_juzgado	    char(50);
define v_nombre_depto       char(50);
define v_nombre_abogado     char(50);
define _n_demanda           char(18);
DEFINE v_filtros            CHAR(255);
DEFINE _tipo_demanda		smallint;
DEFINE v_compania_nombre    CHAR(50);
define _tipo				char(1);
define _codigo  			char(25);
define _honorario           dec(16,2);
define _reserva             dec(16,2);
define _obs                 varchar(255);
--define _fecha               datetime;

set isolation to dirty read;

let _juzgado = null;
let _reserva = 0;
let _honorario = 0;
--let _fecha = current;

FOREACH
 SELECT no_demanda,
	    tipo_demanda,
	    demandante,
	    demandado,
	    numrecla,
		cod_abogado,
		cod_depto,
		estatus_actual,
		honorario_legal,
		instancia,
		expediente,
		pronostico,
		monto_cuantia,
		reserva,
		observacion
   INTO _no_demanda,
  	    _tipo_demanda,
  	    _demandante,
  	    _demandado,
  	    _numrecla,
  	    _cod_abogado,
		_cod_depto,
		_estatus_actual,
		_honorario,
		_instancia,
		_expediente,
		_pronostico,
		_monto_cuantia,
		_reserva,
		_obs
   FROM legdemanbk
  
  let _demandante = upper(_demandante);
  let _demandado  = upper(_demandado);
  
  if _numrecla is not null then
	 select cod_asegurado
	   into _cod_asegurado
	   from recrcmae
	  where numrecla = _numrecla; 
  end if
  if _demandante is null then
	let _demandante = ' ';
  end if
  if _demandado is null then
	let _demandado = ' ';
  end if  

	INSERT INTO legdeman(
		no_demanda,
	    tipo_demanda,
	    demandante,
	    demandado,
	    numrecla,
		cod_asegurado,
		cod_abogado,
		cod_depto,
		juzgado,
		estatus_actual,
		instancia,
		expediente,
		pronostico,
		monto_cuantia,
		tot_honorario_legal,
		tot_reserva,
		user_added,
		date_added,
		user_modifico,
		date_modifico,
		honorario_legal,
		observacion
	)
	VALUES(
		_no_demanda,
  	    _tipo_demanda,
  	    _demandante,
  	    _demandado,
  	    _numrecla,
  	    _cod_asegurado,
  	    _cod_abogado,
		_cod_depto,
		_juzgado,
		_estatus_actual,
		_instancia,
		_expediente,
		_pronostico,
		_monto_cuantia,
		_honorario,
		_reserva + _honorario,
		'MPICH',
		current,
		'MPICH',
		current,
		_honorario,
		_obs
	);

END FOREACH;
return 0;
END PROCEDURE;