-- Procedimiento que crea rectrmae

-- Creado    : 02/05/2014 - Autor: Amado Perez M. 

--drop procedure sp_rwf120;
drop procedure sp_tem03;

create procedure sp_tem03(a_numrecla char(20), a_transaccion char(10), a_cod_tipotran char(3), a_cod_tipopago char(3), a_cod_cliente char(10), a_user_name_ajust CHAR(20), a_genera_cheque smallint) 
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
define _no_reclamo          char(10);

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

 if trim(a_cod_tipopago) = "" Then
	let a_cod_tipopago = null;
 end if


 select usuario
   into _user_added
   from insuser
  where windows_user = trim(a_user_name_ajust);
  
select no_reclamo 
  into _no_reclamo 
  from recrcmae
 where numrecla = a_numrecla;  

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
 where no_reclamo = _no_reclamo;

select cod_ramo
  into _cod_ramo
  from emipomae
 where no_poliza = _no_poliza;

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
user_added,
yoseguro
)
VALUES(
_no_tranrec_char,
_cod_compania,
_cod_sucursal,
_no_reclamo,
_cod_cliente,
a_cod_tipotran,
a_cod_tipopago,
null,
null,
null,
_numrecla,
_fecha_no_server,
0,
a_transaccion, --transaccion
0,
_cerrar_rec,
0,
_periodo_rec,
0,
0,
0,
a_genera_cheque,
0,
_user_added,
1
);


end
commit work;

return 0, "Actualizacion Exitosa", _no_tranrec_char;

end procedure