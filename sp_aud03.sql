-- Procedimiento que Crea los Registros para los Auditores
-- 
-- Creado     : 15/09/2004 - Autor: Demetrio Hurtado
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_aud03;

create procedure "informix".sp_aud03(a_fecha date)
returning integer,
          char(50);

define _no_documento	char(20);
define _no_poliza		char(10);	
define _cod_asegurado	char(10);
define _nombre			char(100);
define _cod_ramo		char(3);
define _ramo			char(50);
define _cod_tipoprod	char(3);
define _fecha_emision	date;
define _fecha_pago		date;
define _vigencia_inic	date;
define _vigencia_final	date;
define _periodo			char(7);

DEFINE _por_vencer_tot  DEC(16,2);
DEFINE _exigible_tot    DEC(16,2);
DEFINE _corriente_tot   DEC(16,2);
DEFINE _monto_30_tot    DEC(16,2);
DEFINE _monto_60_tot    DEC(16,2);
DEFINE _monto_90_tot    DEC(16,2);
DEFINE _saldo_tot       DEC(16,2);

DEFINE _prima_orig	    DEC(16,2);
define _fecha_hora1		datetime year to fraction(5);
define _fecha_hora2		datetime year to fraction(5);

define _cod_origen		char(3);
define _nombre_origen	char(10);
define _tiene_impuesto	smallint;
define _impuesto_char	char(2);

--set debug file to "sp_aud03.trc";
--trace on;

let _periodo = sp_sis39(a_fecha);

{
drop table cobmoaud;

create table cobmoaud(
	no_documento	char(20),
    vigencia_inic	date,
    vigencia_final	date,
	nombre			char(100),
	ramo			char(50),
	fecha_emision	date,			
	fecha_pago		date,
	prima_orig		dec(16,2),
	saldo			dec(16,2),
	monto_vencer	dec(16,2),       
    monto_corriente	dec(16,2),        
    monto_30		dec(16,2),         
    monto_60		dec(16,2),         
    monto_90		dec(16,2),
	origen			char(10),
	impuesto		char(2)
);

alter table cobmoaud lock mode (row);
--}

{
drop table cobmotime;

create table cobmotime(
	no_documento	char(20),
	fecha_inicio	datetime year to fraction(5),
	fecha_fin		datetime year to fraction(5),
	saldo			dec(16,2)
	);

alter table cobmotime lock mode (row);
--}

delete from cobmoaud;
--delete from cobmotime;

set isolation to dirty read;

let _por_vencer_tot = 0.00;       
let _exigible_tot	= 0.00;         
let _corriente_tot	= 0.00;        
let _monto_30_tot	= 0.00;         
let _monto_60_tot	= 0.00;         
let _monto_90_tot	= 0.00;
let _saldo_tot		= 0.00;         

FOREACH 
 SELECT no_documento
   INTO	_no_documento
   FROM emipoliza
--  where no_documento = "0205-00894-01"	

--	let _fecha_hora1 = sp_sis40();

	let _no_poliza = sp_sis21(_no_documento);

	if _no_poliza is null then
		continue foreach;
	end if

	select cod_tipoprod,
		   cod_contratante,
		   cod_ramo,
		   fecha_suscripcion,
		   vigencia_inic,
		   vigencia_final,
		   cod_origen
	  into _cod_tipoprod,
		   _cod_asegurado,
		   _cod_ramo,
		   _fecha_emision,
		   _vigencia_inic,
		   _vigencia_final,
		   _cod_origen
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_tipoprod not in ("001", "005") then
		continue foreach;
	end if

--{
	CALL sp_cob06(
		 _no_documento,
		 _periodo,
		 a_fecha
		 ) RETURNING _por_vencer_tot,       
    				 _exigible_tot,         
    				 _corriente_tot,        
    				 _monto_30_tot,         
    				 _monto_60_tot,         
    				 _monto_90_tot,
					 _saldo_tot;         
--}
  				 
{
	let _fecha_hora2 = sp_sis40();
	
	insert into cobmotime
	values (_no_documento, _fecha_hora1, _fecha_hora2, _saldo_tot);
}

 	IF _saldo_tot = 0 THEN                   
		CONTINUE FOREACH;
 	END IF                                      

	if _cod_origen = "001" then

		let _nombre_origen = "LOCAL";

		select count(*)
		  into _tiene_impuesto
		  from emipolim
		 where no_poliza = _no_poliza;

		if _tiene_impuesto >= 1 then
			let _impuesto_char = "SI";
		else
			let _impuesto_char = "NO";
		end if

	else

		let _nombre_origen = "EXTERIOR";
		let _impuesto_char = "NO";

	end if

	
	select max(fecha_ult_pago)
	  into _fecha_pago
	  from emipomae
	 where no_documento = _no_documento
	   and actualizado  = 1;

	if _fecha_pago is null or
	   _fecha_pago = " "   then
		let _fecha_pago = "01/01/1900";
	end if

	select nombre
	  into _nombre
	  from cliclien
	 where cod_cliente = _cod_asegurado;

	select nombre
	  into _ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	select prima_bruta
	  into _prima_orig
	  from endedmae
	 where no_poliza = _no_poliza
	   and no_endoso = "00000";
	    
	if _prima_orig is null then
		let _prima_orig = 0.00;
	end if

	if _vigencia_inic is null or
	   _vigencia_inic = " " then 
		let _vigencia_inic  = mdy(1,1,1900);
	end if

	if _vigencia_final is null or 
	   _vigencia_final = " " then 
		let _vigencia_final = mdy(1,1,1900);
	end if

	insert into cobmoaud
	values(
	_no_documento,
    _vigencia_inic,
    _vigencia_final,
	_nombre,
	_ramo,
	_fecha_emision,
	_fecha_pago,
	_prima_orig,
	_saldo_tot,
	_por_vencer_tot,       
    _corriente_tot,        
    _monto_30_tot,         
    _monto_60_tot,         
    _monto_90_tot,
	_nombre_origen,
	_impuesto_char
	);
					 
end foreach

return 0, "Actualizacion Exitosa";

--unload to facturas.txt select * from tmp_polizas;

end procedure