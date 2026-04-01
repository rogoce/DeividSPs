-- Polizas sin pago
-- Modificado: 23/08/2019 - Henry Giron
-- SIS v.2.0 - d_cobr_sp_cob423_dw1 - DEIVID, S.A.

drop procedure sp_cob423;
create procedure sp_cob423(
a_compania char(3),
a_sucursal char(3)
)
returning char(20),
		  date,
		  date,	
          char(100),
		  char(10),
		  date,
		  char(1),
		  char(50),
		  decimal(16,2),
		  char(50);

define _no_poliza		char(10);
define _no_recibo		char(10);
define _no_documento	char(20);
define _vigencia_inic	date;
define _vigencia_final,_fecha_cancelacion	date;
define _cod_contratante	char(10);
define _fecha_suscrip	date;
define _actualizado		smallint;

define _nombre			char(100);
define _estatus 	char(1);
define v_nombre_cia		char(50);
define _estatus_poliza smallint;
define _prima_bruta  decimal(16,2);
define _estatus_desc   char(50);
set isolation to dirty read;

LET  v_nombre_cia = sp_sis01(a_compania); 

foreach
 select no_poliza,
        no_recibo,
		no_documento,
		vigencia_inic,
		vigencia_final,
		cod_contratante,
		fecha_suscripcion,		
		estatus_poliza,
		prima_bruta
   into	_no_poliza,
        _no_recibo,
		_no_documento,
		_vigencia_inic,
		_vigencia_final,
		_cod_contratante,
		_fecha_suscrip,		
		_estatus_poliza,
		_prima_bruta
   from emipomae
  where actualizado = 1
    and no_poliza in(select no_poliza from emipoagt
                            where cod_agente = '02569')
 

   foreach
	   select d.no_recibo
		 into _no_recibo
		 from  cobredet d
		where d.actualizado = 1
	      and d.doc_remesa = _no_documento   
	
		exit foreach;
	end foreach

	select nombre
	  into _nombre
	  from cliclien
	 where cod_cliente = _cod_contratante;
	 
	if _estatus_poliza = 1 then
			let _estatus_desc = "VIGENTE";
		elif _estatus_poliza = 2 then
			let _estatus_desc = "CANCELADA";
		elif _estatus_poliza = 3 then
			let _estatus_desc = "VENCIDA";
		elif _estatus_poliza = 4 then
			let _estatus_desc = "ANULADA";
	end if	 

	return _no_documento,
		   _vigencia_inic,
		   _vigencia_final,
		   _nombre,
		   _no_recibo,
		   _fecha_suscrip,
		   _estatus_poliza,
		   v_nombre_cia,
		   _prima_bruta,
		   _estatus_desc
		   with resume;

end foreach
end procedure;