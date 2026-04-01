-- Procedimiento que busca información del estatus de un tramite

-- Creado:	25/06/2014 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_json05;
 
create procedure sp_json05(a_tramite CHAR(10), a_cedula CHAR(30))
returning CHAR(20), VARCHAR(100), CHAR(20), CHAR(50), char(50);

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
define _cant_ase        smallint;
define _cod_ruta        char(2);
define _nombre_ruta     char(50);
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
let _nombre_ruta = "";
let _cod_ruta    = "";

set isolation to dirty read;

select cod_cliente,
	   nombre
  into _cod_cliente,
	   _nombre
  from cliclien
 where cedula = a_cedula;
	
select no_reclamo,
	   numrecla,
	   estatus_reclamo
  into _no_reclamo,
       _numrecla,
	   _estatus_reclamo
  from recrcmae
where no_tramite = a_tramite;

select count(*)
  into _cant_ase
  from recrcmae
 where no_reclamo = _no_reclamo
   and cod_asegurado = _cod_cliente;
   
if _cant_ase = 0 then
	return " ", " ", " ", " ", " ";
end if
	
select doc_completa,
       date_doc_comp
  into _doc_completa,
	   _date_added
  from recrcmae
 where no_reclamo = _no_reclamo;
   
if _no_reclamo is null then
	return " ", " ", " ", " ", " ";
end if

if _cod_cliente is null then
	return " ", " ", " ", " ", " ";
end if

if _doc_completa = 0 then
	if year(_date_added) < 2016 OR _estatus_reclamo = 'C' then
		let _doc_comp = 'COMPLETADO';
	else
		let _doc_comp = 'ABIERTO';
		let _mensaje  = 'DOCUMENTACION INCOMPLETA - ';
	end if
end if
--else
	--let _doc_comp = 'ABIERTO';
	
	select count(*)
	  into _cant_r1
	  from rectrmae 
	 where no_reclamo = _no_reclamo
	   and cod_tipotran = '004'
	   and cod_tipopago = '003' --Pago a Asegurado
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
	   and cod_tipopago = '003' --Pago a Asegurado
	   and actualizado = 1
	   and no_requis is not null
	   and anular_nt is null
	   and pagado = 1
	   and cod_cliente = _cod_cliente;
	
    if _cant_r1 = 0 and _cant_r2 = 0  and _doc_completa = 1 then	
		let _doc_comp = 'EN TRAMITE';
	elif _cant_r1 > 0 and _cant_r2 >= 0 then
		let _doc_comp = 'EN TRAMITE';
		foreach
			select no_requis
			  into _no_requis
			  from rectrmae 
			 where no_reclamo = _no_reclamo
			   and cod_tipotran = '004'
			   and cod_tipopago = '003'
			   and actualizado = 1
			   and no_requis is not null
			   and anular_nt is null
			   and pagado = 0
			   and cod_cliente = _cod_cliente
            exit foreach;
		end foreach
		
		select en_firma,
			   cod_ruta
		  into _en_firma,
		       _cod_ruta
		  from chqchmae
		 where no_requis = _no_requis;
		 
		if _en_firma in(0,4) then
			--let _mensaje = "";
		elif _en_firma = "1" then
			let _mensaje = _mensaje || "EN FIRMA";
		elif _en_firma = "2" then
			let _mensaje = _mensaje || "FIRMADO";
		elif _en_firma = "5" then
			let _mensaje = _mensaje || "DECLINADO";
		else
			let _mensaje = "";
		end if
		 
	elif _cant_r1 = 0 and _cant_r2 > 0 then
        let _doc_comp = 'COMPLETADO';
		foreach
			select no_requis
			  into _no_requis
			  from rectrmae 
			 where no_reclamo = _no_reclamo
			   and cod_tipotran = '004'
			   and cod_tipopago = '003'
			   and actualizado = 1
			   and no_requis is not null
			   and anular_nt is null
			   and pagado = 1
			   and cod_cliente = _cod_cliente
            exit foreach;
		end foreach
		
		select wf_entregado,
			   cod_ruta
		  into _wf_entregado,
		       _cod_ruta
		  from chqchmae
		 where no_requis = _no_requis;
		 
		if _wf_entregado = 1 then
			let _mensaje = _mensaje || "ENTREGADO";
		else
			let _mensaje = _mensaje || "IMPRESO";
		end if
	end if
--end if

	select nombre
	  into _nombre_ruta
	  from chqruta 
	 where cod_ruta = _cod_ruta;
		 
return _numrecla, _nombre, _doc_comp, _mensaje, _nombre_ruta;

end procedure
