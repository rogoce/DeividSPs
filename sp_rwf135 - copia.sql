-- Procedimiento que aumenta o disminuye la reserva o cierra el reclamo

-- Creado    : 02/05/2014 - Autor: Amado Perez M. 

--drop procedure sp_rwf120;
drop procedure sp_rwf135;

create procedure sp_rwf135(a_no_reclamo char(10), a_opcion smallint, a_monto dec(16,2), a_user_name_ajust CHAR(20), a_cod_cobertura CHAR(5)) 
  returning integer,
            char(50),
            char(10);

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

set isolation to dirty read;

--set debug file to "sp_rwf125.trc";
--trace on;

begin work;

begin 
on exception set _error, _error_isam, _error_desc
	rollback work;
	return _error, _error_desc, null;
end exception

let _reserva_actual = 0; 
let _cerrar_rec = 0; 
let _cod_cobertura = a_cod_cobertura;
let a_user_name_ajust = upper(a_user_name_ajust);

if a_monto < 0 then
	let a_monto = a_monto * (-1);
end if

 select usuario
   into _user_added
   from insuser
  where windows_user = trim(a_user_name_ajust);


select cod_compania,
       cod_sucursal,
	   numrecla,
	   cod_asegurado,
	   no_poliza,
	   reserva_actual
  into _cod_compania,
       _cod_sucursal,
	   _numrecla,
	   _cod_cliente,
	   _no_poliza,
	   _reserva_actual
  from recrcmae
 where no_reclamo = a_no_reclamo;

select cod_ramo
  into _cod_ramo
  from emipomae
 where no_poliza = _no_poliza;

select reserva_actual
  into _reserva_cob
  from recrccob
 where no_reclamo = a_no_reclamo
   and cod_cobertura = _cod_cobertura;


let _descripcion = null;

if _cod_ramo = '018' then		 --cuando es salud se evalua de recrcmae
	let _reserva_cob = _reserva_actual;
end if

if a_opcion = 1 then			 -- Aumento 
    LET _cod_tipotran = '002';
	LET _variacion = a_monto;
	LET _descripcion = "AUMENTO DESDE EL CONTROL DE RESERVAS POR EL AJUSTADOR"; 
elif a_opcion = 2 then
    LET _cod_tipotran = '003';	 -- Disminucion
	LET _descripcion = "DISMINUCION DESDE EL CONTROL DE RESERVAS POR EL AJUSTADOR"; 

	IF _reserva_cob IS NULL THEN
		LET _reserva_cob = 0.00;
	END IF

	IF _reserva_cob < 0 THEN
		LET _reserva_cob = 0.00;
	END IF

	IF a_monto > 0.00 THEN
		IF a_monto > _reserva_cob THEN
			LET _variacion = _reserva_cob * (-1);
		ELSE
			LET _variacion = a_monto * (-1);
		END IF
	ELSE
		LET _variacion = 0.00;
	END IF
elif a_opcion = 3 then		 	-- Proceso que cierra las reservas
	LET _cod_tipotran =  "011";
    LET _cerrar_rec = 1; 
	LET _descripcion = "CIERRE DESDE EL CONTROL DE RESERVAS POR EL AJUSTADOR"; 

	select sum(variacion)
	  into _variacion
	  from rectrmae
	 where no_reclamo   = a_no_reclamo
	   and actualizado  = 1;

	if _variacion is null then
		let _variacion = 0.00;
	end if

    let a_monto = _variacion;
    let _variacion = _variacion * (-1);

end if


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
user_added
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
null,
0,
_cerrar_rec,
0,
_periodo_rec,
0,
a_monto,
_variacion,
0,
0,
_user_added
);

-- Insercion de las Coberturas (Transacciones)
IF a_opcion = 3 THEN
	FOREACH
		SELECT cod_cobertura,
			   reserva_actual
		  INTO _cod_cobertura,
			   _reserva_actual
		  FROM recrccob
		 WHERE no_reclamo = a_no_reclamo

		IF _reserva_actual < 0 THEN
			LET _reserva_actual = 0;
		END IF

		LET _cant = 0; 

		SELECT COUNT(*) 			 --> Se verifica que esten todas las coberturas al cerrar el reclamo, si no esta se incluye
		  INTO _cant
		  FROM rectrcob
		 WHERE no_tranrec = _no_tranrec_char
		   AND cod_cobertura = _cod_cobertura;

		IF _cant > 0 THEN
			UPDATE rectrcob
			   SET monto = _reserva_actual,
			       variacion = _reserva_actual * -1
			 WHERE no_tranrec = _no_tranrec_char
			   AND cod_cobertura = _cod_cobertura;
		ELSE
			INSERT INTO rectrcob (
					no_tranrec,
					cod_cobertura,
					monto,
					variacion
					)
			VALUES (_no_tranrec_char,
					_cod_cobertura,
					_reserva_actual,
					_reserva_actual * -1
					);
		END IF

	END FOREACH
ELSE
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
END IF

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

-- Insertando RECNOTAS
LET _hoy = CURRENT;
LET _hoy = _hoy + 1 units second;
CALL sp_rwf104(a_no_reclamo,_hoy, _descripcion || ", SUBIO A APROBACION",_user_added) returning _error, _error_desc;
IF _error <> 0 THEN
	rollback work;
	RETURN  _error, _error_desc, null;
END IF

end
commit work;

return 0, "Actualizacion Exitosa", _no_tranrec_char;

end procedure