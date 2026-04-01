-- Procedimiento que cierra la reserva del reclamo

-- Creado    : 27/06/2008 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_rec158a;
create procedure sp_rec158a(
a_no_reclamo char(10),
a_reserva	 dec(16,2)
) returning integer,
            char(50);

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
DEFINE _cod_tipotran    	CHAR(3);
DEFINE _estatus_reclamo    	CHAR(1);
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

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

let _reserva_actual = 0;

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

select sum(reserva_actual)
  into _reserva_cob
  from recrccob
 where no_reclamo = a_no_reclamo;

if _cod_ramo = '018' then		 --cuando es salud se evalua de recrcmae
	let _reserva_cob = _reserva_actual;
	let _cod_tipotran = '003';
	let _estatus_reclamo = 'A';
else
	let _cod_tipotran = '011';
	let _estatus_reclamo = 'C';
end if

if _reserva_cob <> a_reserva then
	return 1, "Reservas de Reclamos Vs Coberturas No Cuadran";
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
LET _no_tran_char    = sp_sis12(_cod_compania, _cod_sucursal, a_no_reclamo);
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
_no_tran_char,
0,
1,
0,
_periodo_rec,
1,
a_reserva,
a_reserva * -1,
0,
1,
"informix"
);

-- Insercion de las Coberturas (Transacciones)

if _cod_ramo = '018' then		 --cuando es salud escogemos una cobertura Amado 27/06/2012 a veces no coincide la reserva de las coberturas con lo que esta en recrcmae
	foreach
	 select cod_cobertura
	   into _cod_cobertura
	   from recrccob
	  where no_reclamo = a_no_reclamo
	 exit foreach;
	end foreach
    
	INSERT INTO rectrcob(
	no_tranrec,
	cod_cobertura,
	monto,
	variacion
	)
	VALUES(
    _no_tranrec_char,
	_cod_cobertura,
	_reserva_cob,
	_reserva_cob * -1
	);
else
	foreach
	 select cod_cobertura,
	   		reserva_actual
	   into _cod_cobertura,
	        _reserva_cob
	   from recrccob
	  where no_reclamo = a_no_reclamo

		INSERT INTO rectrcob(
		no_tranrec,
		cod_cobertura,
		monto,
		variacion
		)
		VALUES(
	    _no_tranrec_char,
		_cod_cobertura,
		_reserva_cob,
		_reserva_cob * -1
		);

	end foreach
end if

update recrcmae
   set reserva_actual  = 0,
       estatus_reclamo = _estatus_reclamo
 where no_reclamo      = a_no_reclamo;
  
update recrccob
   set reserva_actual  = 0
 where no_reclamo      = a_no_reclamo;
        
-- Reaseguro a Nivel de Transaccion

call sp_sis58(_no_tranrec_char) returning _error, _error_desc;

if _error <> 0 then
	return _error, _error_desc;
end if

end

return 0, "Actualizacion Exitosa";

end procedure