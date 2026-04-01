-- Procedimiento para adicionar una cobertura al reclamo y si es necesario crear el aumento de reserva

-- Creado    : 20/12/2014 - Autor: Amado Perez M. 

drop procedure sp_rwf169;

create procedure sp_rwf169(a_no_tramite char(10), a_monto dec(16,2), a_user_name_ajust CHAR(20), a_cod_cobertura CHAR(5), a_deducible DEC(16,2)) 
  returning integer,
            char(50),
            char(10),
			smallint;

define _cod_compania		char(3);
define _cod_sucursal		char(3);
define _reserva_cob			dec(16,2);

DEFINE _cod_cobertura   	CHAR(5);  
DEFINE _cod_cliente     	CHAR(10); 
DEFINE _numrecla        	CHAR(18); 

DEFINE _no_tranrec_char 	CHAR(10); 
DEFINE _no_tran_char    	CHAR(10); 

DEFINE _version		    	CHAR(2);
DEFINE _aplicacion	    	CHAR(3);
DEFINE _valor_parametro 	CHAR(20);
DEFINE _valor_parametro2	CHAR(20);
DEFINE _fecha_no_server  	DATE;
DEFINE _periodo_rec     	CHAR(7);  

define _error				integer;
define _error_isam			integer;
define _error_desc			char(50);
define _no_poliza           char(10);
define _reserva_actual      decimal(16,2);
define _cod_ramo            char(3);
define _variacion           dec(16,2);
define _cod_tipotran        char(3);
define _cod_cobertura_rec   char(5);
define _user_added          char(8);
define _cerrar_rec          smallint;
define _descripcion         varchar(60);
define _hoy                 DATETIME HOUR TO FRACTION(5);
define _cant                smallint;
define _aprobar             smallint;
define _lim_min_reserva     dec(16,2);
define _actualizado         smallint;

define _monto_tr            dec(16,2);
define _variacion_sum       dec(16,2);
DEFINE _transaccion			CHAR(10);
define a_no_reclamo         CHAR(10);

set isolation to dirty read;

--set debug file to "sp_rwf166.trc";
--trace on;



begin 
on exception set _error, _error_isam, _error_desc
	rollback work;
	return _error, _error_desc, "", 0;
end exception

let _reserva_actual = 0; 
let _cerrar_rec = 0; 
let _cod_cobertura = a_cod_cobertura;
let a_user_name_ajust = upper(a_user_name_ajust);
let _aprobar = 0;
let _actualizado = 0;
LET _transaccion = null;
LET _no_tranrec_char = NULL;

 select usuario
   into _user_added
   from insuser
  where windows_user = trim(a_user_name_ajust);


select cod_compania,
       cod_sucursal,
	   numrecla,
	   cod_asegurado,
	   no_poliza,
	   reserva_actual,
	   no_reclamo
  into _cod_compania,
       _cod_sucursal,
	   _numrecla,
	   _cod_cliente,
	   _no_poliza,
	   _reserva_actual,
	   a_no_reclamo
  from recrcmae
 where no_tramite = a_no_tramite;

select cod_ramo
  into _cod_ramo
  from emipomae
 where no_poliza = _no_poliza;

select count(*)
  into _cant
  from recrccob
 where no_reclamo = a_no_reclamo
   and cod_cobertura = _cod_cobertura;
   
if _cant > 0 then
	return 1, "Cobertura ya existe", "", 0;
end if
begin work;
Insert into recrccob (
   no_reclamo, 
   cod_cobertura, 
   reserva_inicial, 
   reserva_actual, 
   deducible)
   values (
   a_no_reclamo, 
   a_cod_cobertura, 
   0, 
   0, 
   a_deducible);

if a_monto > 0 then			 -- Aumento 
    LET _cod_tipotran = '002';
	LET _variacion = a_monto;
	LET _descripcion = "AUMENTO DESDE YOSEGURO"; 

	let _aplicacion = "REC";

	SELECT version
	  INTO _version
	  FROM insapli
	 WHERE aplicacion = _aplicacion;

	SELECT valor_parametro
	  INTO _valor_parametro
	  FROM inspaag
	 WHERE codigo_compania  = _cod_compania
	   AND aplicacion       = _aplicacion
	   AND version          = _version
	   AND codigo_parametro	= 'fecha_recl_default';

	IF TRIM(_valor_parametro) = '1' THEN   --Toma la fecha del servidor

		LET _fecha_no_server = CURRENT;				

	ELSE								   --Toma la fecha de un parametro establecido por computo.

		SELECT valor_parametro			  
		  INTO _valor_parametro2
		  FROM inspaag
		 WHERE codigo_compania  = _cod_compania
		   AND aplicacion       = _aplicacion
		   AND version          = _version
		   AND codigo_parametro	= 'fecha_recl_valor';

		LET _fecha_no_server = DATE(_valor_parametro2);				

	END IF

	IF MONTH(_fecha_no_server) < 10 THEN
		LET _periodo_rec = YEAR(_fecha_no_server) || "-0" || MONTH(_fecha_no_server);
	ELSE
		LET _periodo_rec = YEAR(_fecha_no_server) || "-" || MONTH(_fecha_no_server);
	END IF

	-- Asignacion del Numero Interno y Externo de Transacciones

	--LET _no_tran_char = null;
	LET _no_tranrec_char = sp_sis13(_cod_compania, _aplicacion, _version, 'par_tran_genera');

	 -- Buscando # de transaccion externo
	LET _transaccion = NULL;
	IF _aprobar = 0 THEN
		LET _actualizado = 1;
		LET _transaccion = sp_sis12(_cod_compania, _cod_sucursal, a_no_reclamo);

		IF _transaccion = "" OR _transaccion IS NULL THEN
			rollback work;
			RETURN 1, "Error generando # de transaccion", "", 0;
		END IF
	END IF

	INSERT INTO rectrmae(
	no_tranrec,
	cod_compania,
	cod_sucursal,
	no_reclamo,
	cod_cliente,
	cod_tipotran,
	cod_tipopago,
	no_requis,
	no_remesa,
	renglon,
	numrecla,
	fecha,
	impreso,
	transaccion,
	perd_total,
	cerrar_rec,
	no_impresion,
	periodo,
	pagado,
	monto,
	variacion,
	generar_cheque,
	actualizado,
	user_added,
	yoseguro
	)
	VALUES(
	_no_tranrec_char,
	_cod_compania,
	_cod_sucursal,
	a_no_reclamo,
	_cod_cliente,
	_cod_tipotran,
	null,
	null,
	null,
	null,
	_numrecla,
	_fecha_no_server,
	0,
	_transaccion,
	0,
	_cerrar_rec,
	0,
	_periodo_rec,
	0,
	a_monto,
	_variacion,
	0,
	_actualizado,
	_user_added,
	1
	);

	INSERT INTO rectrcob(
	no_tranrec,
	cod_cobertura,
	monto,
	variacion
	)
	VALUES(
	_no_tranrec_char,
	_cod_cobertura,
	a_monto,
	_variacion
	);

	--Insertando en la descripcion

	INSERT INTO rectrde2(
	no_tranrec,
	renglon,
	desc_transaccion
	)
	VALUES(
	_no_tranrec_char,
	1,
	_descripcion
	);

	if _aprobar = 0 then
		 
		-- Actualizando coberturas
	 
		BEGIN
			ON EXCEPTION SET _error 
				rollback work;
				RETURN _error, "Error al actualizar las coberturas del reclamo", "", 0;         
			END EXCEPTION 
			FOREACH
				SELECT cod_cobertura,
					   variacion
				  INTO _cod_cobertura,
					   _variacion
				  FROM rectrcob
				 WHERE no_tranrec = _no_tranrec_char

				UPDATE recrccob
				   SET reserva_actual = reserva_actual + _variacion
				 WHERE no_reclamo     = a_no_reclamo
				   AND cod_cobertura  = _cod_cobertura;

			END FOREACH
		END

		-- Reaseguro a Nivel de Transaccion
		CALL sp_sis58(_no_tranrec_char) returning _error, _descripcion;

		IF _error = 1 THEN
			rollback work;
			RETURN  _error, "No se creo el Reaseguro a Nivel de Transaccion","",0;
		END IF
		 
	else
		-- Insertando RECNOTAS
		LET _hoy = CURRENT;
		LET _hoy = _hoy + 1 units second;
		CALL sp_rwf104(a_no_reclamo,_hoy, _descripcion || ", SUBIO A APROBACION",_user_added) returning _error, _error_desc;
		IF _error <> 0 THEN
			rollback work;
			RETURN  _error, _error_desc, "", 0;
		END IF
	end if
end if
end

commit work;

if _no_tranrec_char is null then
	let _no_tranrec_char = "";
end if

return 0, "Actualizacion Exitosa", _no_tranrec_char, _aprobar;

end procedure