-- Procedimiento que crea transaccion de reclamos para actualizacion de ajuste de orden de rep o compra

-- Creado    : 07/10/2014 - Autor: Armando Moreno M.

drop procedure sp_rec725;

create procedure sp_rec725(a_no_reclamo char(10), a_monto dec(16,2),a_cod_proveedor char(10), a_transaccion char(10), a_no_ajuste char(10), a_renglon smallint, a_usuario char(8), a_por_precio smallint default 0, a_tipo_opc smallint default 0,a_orden char(10))
returning integer,
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
define _cod_tipopago        char(3);
define _no_tranrec          char(10);
define _cod_concepto        char(3);
define _tipo_ajuste         char(1);
define a_monto_pagar        dec(16,2);

set isolation to dirty read;

--set debug file to "sp_rec728.trc";
--trace on;


begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

let _reserva_actual = 0;

select cod_tipopago,
       no_tranrec
  into _cod_tipopago,
       _no_tranrec
  from rectrmae
 where transaccion = a_transaccion;	--ntr inicial

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

-- Asignacion del Numero Interno

LET _no_tranrec_char = sp_sis13(_cod_compania, _aplicacion, _version, 'par_tran_genera'); --interno

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
a_cod_proveedor,
"004",
"001",
null,
null,
null,
_numrecla,
_fecha_no_server,
0,
null,	--> debe ir en nulo porque primero se debe ir a aprobacion
0,
0,
0,
_periodo_rec,
0,
a_monto,
a_monto * -1,
0,
0,
a_usuario
);


--COBERTURAS

select * 
  from rectrcob
 where no_tranrec = _no_tranrec
   and monto      <> 0
  into temp prueba;

update prueba 
   set no_tranrec = _no_tranrec_char,
       monto      = a_monto,
	   variacion  = a_monto * -1,
	   subir_bo   = 0
 where no_tranrec = _no_tranrec;

insert into rectrcob
select * 
  from prueba
 where no_tranrec = _no_tranrec_char;

drop table prueba;

--CONCEPTO

let a_monto_pagar = 0;
if a_tipo_opc = 0 then
	select * 
	  from rectrcon
	 where no_tranrec = _no_tranrec
	   and cod_concepto in ('003','017') -- Se filtro solo chapisteria y piezas porque estaba trayendo otro concepto como el de descuenta deducible y salian mal las transacciones Amado 16-12-2014
	  into temp prueba;

	update prueba 
	   set no_tranrec = _no_tranrec_char,
	       monto      = a_monto,
		   subir_bo   = 0
	 where no_tranrec = _no_tranrec;

	insert into rectrcon
	select * 
	  from prueba
	 where no_tranrec = _no_tranrec_char;

	drop table prueba;

   foreach
	select monto
	  into a_monto_pagar
	  from recordad
	 where no_ajus_orden = a_no_ajuste
	   and no_orden      = a_orden
       and tipo_opc      = 0

	exit foreach;
   end foreach

	call sp_rec728(_no_tranrec_char, a_monto, a_tipo_opc, a_monto_pagar,a_no_ajuste, a_orden,a_por_precio) returning _error, _error_desc;
	if _error <> 0 then
		return _error, _error_desc;
	end if
else
	if a_tipo_opc = 1 then --Alineamiento
		let _cod_concepto = '036';
	elif a_tipo_opc = 2 then --Flete
		let _cod_concepto = '035';
	elif a_tipo_opc = 3 then --Deducible en caja  --> Descuenta deducible
		let _cod_concepto = '006';
	elif a_tipo_opc = 4 then --Deducible Exonerado --> Devolucion de deducible
		let _cod_concepto = '008';
	elif a_tipo_opc = 6 then --Alquiler de Auto
		let _cod_concepto = '022';
	   
	   foreach
		select cod_concepto
		  into _cod_concepto
		  from rectrcon
		 where no_tranrec = _no_tranrec
		exit foreach;
	   end foreach
		
	   foreach
		select monto
		  into a_monto_pagar
		  from recordad
		 where no_ajus_orden = a_no_ajuste
		   and renglon       = a_renglon
	       and tipo_opc      = 6

		exit foreach;
	   end foreach
	elif a_tipo_opc = 7 then --Nota de Credito
		let _cod_concepto = '017';
	elif a_tipo_opc = 8 then --Mecanica
		let _cod_concepto = '013';
	elif a_tipo_opc = 9 then --Aire Acondicionado
		let _cod_concepto = '001';
	elif a_tipo_opc = 10 then --Electromecanica
		let _cod_concepto = '009';
	elif a_tipo_opc = 11 then --Chapisteria
		let _cod_concepto = '003';
	elif a_tipo_opc = 12 then --Otros
		let _cod_concepto = '014';
	end if

	insert into rectrcon (
	   	        no_tranrec,
				cod_concepto,
				monto,
				subir_bo)
		values( _no_tranrec_char,
		        _cod_concepto,
				a_monto,
				0);
    call sp_rec728(_no_tranrec_char, a_monto, a_tipo_opc, a_monto_pagar,a_no_ajuste, a_orden,a_por_precio) returning _error, _error_desc;	 --Inserta la descripcion de la transaccion
	if _error <> 0 then
		return _error, _error_desc;
	end if
end if

if a_tipo_opc = 0 then
	if a_por_precio = 0 then
		if a_monto < 0 then --Estoy haciendo la transaccion negativa
			update recordad
			   set no_tranrec_neg = _no_tranrec_char
			 where no_ajus_orden  = a_no_ajuste
			   and renglon        = a_renglon;

		else				--para la positiva
			update recordad
			   set no_tranrec_pos = _no_tranrec_char
			 where no_ajus_orden  = a_no_ajuste
			   and renglon        = a_renglon;

		end if
	else					--Es por precio mayor o menor, se debe guardar el no_tranrec en campo no_tranrec_pre
			update recordad
			   set no_tranrec_pre = _no_tranrec_char
			 where no_ajus_orden  = a_no_ajuste
			   and renglon        = a_renglon;

	end if
elif a_tipo_opc = 6 then --Alquiler de auto

	update recordad
	   set no_tranrec_neg = _no_tranrec_char
	 where no_ajus_orden  = a_no_ajuste
	   and renglon        = a_renglon;

else
	update recordad
	   set no_tranrec_pre = _no_tranrec_char
	 where no_ajus_orden  = a_no_ajuste
	   and renglon        = a_renglon;
end if

return 0, "Actualizacion Exitosa";
End
end procedure