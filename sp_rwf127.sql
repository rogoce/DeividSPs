-- Procedimiento que verifica si aumenta la reserva

-- Creado    : 02/05/2014 - Autor: Amado Perez M. 

--drop procedure sp_rwf120;
drop procedure sp_rwf127;

create procedure sp_rwf127(a_no_reclamo char(10), a_cod_cobertura char(5) default null, a_monto dec(16,2) default null, a_user_name_ajust CHAR(20)) 
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

define _cod_evento          char(3);
define _suma_asegurada   	decimal(16,2);
define _tipo                smallint;
define a_opcion      		smallint;
define _hoy                 DATETIME HOUR TO FRACTION(5);

set isolation to dirty read;

--if a_no_reclamo in ('452222','451421') then
--	set debug file to "sp_rwf127.trc";
--	trace on;
--end if

begin work;

begin 
on exception set _error, _error_isam, _error_desc
	rollback work;
	return _error, _error_desc, null;
end exception

let _reserva_actual = 0; 
let _reserva_cob = 0; 
let _cerrar_rec = 0; 
let a_cod_cobertura = a_cod_cobertura;
let a_monto = a_monto;
let a_user_name_ajust = upper(a_user_name_ajust);

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
	   cod_evento,
	   suma_asegurada
  into _cod_compania,
       _cod_sucursal,
	   _numrecla,
	   _cod_cliente,
	   _no_poliza,
	   _reserva_actual,
	   _cod_evento,
	   _suma_asegurada
  from recrcmae
 where no_reclamo = a_no_reclamo;

if a_cod_cobertura is null or trim(a_cod_cobertura) = "" then
	rollback work;
	return 1, "El codigo de cobertura esta nulo", null;
end if

select sum(a.variacion)
  into _reserva_cob
  from rectrcob a, rectrmae b
 where a.no_tranrec = b.no_tranrec
   and b.no_reclamo = a_no_reclamo
   and a.cod_cobertura = a_cod_cobertura
   and b.actualizado = 1;

if _reserva_cob is null then
	let _reserva_cob = 0.00;
end if

if _reserva_cob >= a_monto then
	rollback work;
	return 2, "No necesita transaccion de aumento", null;
end if

-- Nueva reserva inicial 
let a_monto = a_monto - _reserva_cob; 

LET _cod_tipotran = '002';
LET _variacion = a_monto;

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

LET _no_tran_char = null;
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

INSERT INTO rectrcob(
no_tranrec,
cod_cobertura,
monto,
variacion
)
VALUES(
_no_tranrec_char,
a_cod_cobertura,
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
"AUMENTO DE RESERVA AUTOMATICO DEBIDO A QUE LA COTIZACION"
);

INSERT INTO rectrde2(
no_tranrec,
renglon,
desc_transaccion
)
VALUES(
_no_tranrec_char,
2,
"SUPERA LA RESERVA ACTUAL DEL PROVEEDOR"
);


-- Insertando RECNOTAS
LET _hoy = CURRENT;
LET _hoy = _hoy + 1 units second;
CALL sp_rwf104(a_no_reclamo,_hoy,"AUMENTO DE RESERVA AUTOMATICO DEBIDO A QUE LA COTIZACION SUPERA LA RESERVA ACTUAL DEL PROVEEDOR, SUBIO A APROBACION",_user_added) returning _error, _error_desc;
IF _error <> 0 THEN
	rollback work;
	RETURN  _error, _error_desc, "";
END IF
  

end
commit work;

return 0, "Actualizacion Exitosa", _no_tranrec_char;

end procedure