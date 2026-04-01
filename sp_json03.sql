-- Procedimiento que busca información del estatus de un tramite

-- Creado:	25/06/2014 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_json03;
 
create procedure sp_json03(a_tramite CHAR(10))
returning CHAR(20), CHAR(100);

define _doc_comp		char(20);
define _en_proceso		char(20);
define _terminado		char(20);
define _cod_cliente 	char(10);
define _no_reclamo  	char(10);
define _doc_completa 	smallint;
define _cant_r1     	smallint;
define _cant_r2     	smallint;
define _nombre      	varchar(100);
define _numrecla    	char(20);
define _date_added      date;
define _no_requis       char(10);
define _en_firma        smallint;
define _wf_entregado    smallint;
define _cant_ter        smallint;
----------
define _estatus_reclamo char(20);
define _mensaje         varchar(50);

--set debug file to "sp_proe72.trc";
--trace on;

let _doc_comp = null; 
let _en_proceso = null; 
let _terminado = null; 
let _estatus_reclamo = null;
let _mensaje = "";

set isolation to dirty read;
	
select no_reclamo,
	   numrecla,
	   estatus_reclamo
  into _no_reclamo,
       _numrecla,
	   _estatus_reclamo
  from recrcmae
where no_tramite = a_tramite;

select count(*)
  into _cant_ter
  from recterce
 where no_reclamo = _no_reclamo
   and cod_tercero = _cod_cliente;
   
if _cant_ter = 0 then
	return " ", " ";
end if
	
select doc_completa,
       date_added
  into _doc_completa,
	   _date_added
  from recterce
 where no_reclamo = _no_reclamo
   and cod_tercero = _cod_cliente;
   
if _no_reclamo is null then
	return " ", " ";
end if

if _cod_cliente is null then
	return " ", " ";
end if

if _doc_completa = 0 then
	if year(_date_added) < 2016 OR _estatus_reclamo = 'C' then
		let _doc_comp = 'CERRADO';
	else
		let _doc_comp = 'ABIERTO';
		let _mensaje  = 'DOCUMENTACION INCOMPLETA - ';
	end if
end if
--else
	let _doc_comp = 'ABIERTO';
	
	select count(*)
	  into _cant_r1
	  from rectrmae 
	 where no_reclamo = _no_reclamo
	   and cod_tipotran = '004'
	   and cod_tipopago = '004'
	   and actualizado = 1
	   and no_requis is not null
	   and anular_nt is null
	   and pagado = 0
	   and cod_cliente = _cod_cliente;
	   
 	select count(*)
	  into _cant_r2
	  from rectrmae 
	 where no_reclamo = _no_reclamo
	   and cod_tipotran = '004'
	   and cod_tipopago = '004'
	   and actualizado = 1
	   and no_requis is not null
	   and anular_nt is null
	   and pagado = 1
	   and cod_cliente = _cod_cliente;
	
    if _cant_r1 = 0 and _cant_r2 = 0 then	
		let _doc_comp = 'EN PROCESO';
	elif _cant_r1 > 0 and _cant_r2 = 0 then
		let _doc_comp = 'EN PROCESO';
		foreach
			select no_requis
			  into _no_requis
			  from rectrmae 
			 where no_reclamo = _no_reclamo
			   and cod_tipotran = '004'
			   and cod_tipopago = '004'
			   and actualizado = 1
			   and no_requis is not null
			   and anular_nt is null
			   and pagado = 0
			   and cod_cliente = _cod_cliente
            exit foreach;
		end foreach
		
		select en_firma
		  into _en_firma
		  from chqchmae
		 where no_requis = _no_requis;
		 
		if _en_firma in(0,4) then
			--let _mensaje = "";
		elif _en_firma = "1" then
			let _mensaje = _mensaje || "EN FIRMA";
		elif _en_firma = "2" then
			let _mensaje = _mensaje || "FIRMADO";
		elif _en_firma = "5" then
			let _mensaje = _mensaje || "RECHAZADO";
		else
			let _mensaje = "";
		end if
		 
	elif _cant_r1 = 0 and _cant_r2 > 0 then
        let _doc_comp = 'CERRADO';
		foreach
			select no_requis
			  into _no_requis
			  from rectrmae 
			 where no_reclamo = _no_reclamo
			   and cod_tipotran = '004'
			   and cod_tipopago = '004'
			   and actualizado = 1
			   and no_requis is not null
			   and anular_nt is null
			   and pagado = 1
			   and cod_cliente = _cod_cliente
            exit foreach;
		end foreach
		
		select wf_entregado
		  into _wf_entregado
		  from chqchmae
		 where no_requis = _no_requis;
		 
		if _wf_entregado = 1 then
			let _mensaje = _mensaje || "ENTREGADO";
		else
			let _mensaje = _mensaje || "IMPRESO";
		end if
	end if

return _numrecla, _doc_comp;

end procedure
