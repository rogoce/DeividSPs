-- Procedimiento que busca información del estatus de un tramite

-- Creado:	25/06/2014 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_json03bk;
 
create procedure sp_json03bk(a_tramite CHAR(10))
returning CHAR(20), CHAR(100);

define _doc_comp	char(100);
define _en_proceso	char(20);
define _terminado	char(20);
define _cod_cliente char(10);
define _no_reclamo  char(10);
define _doc_completa smallint;
define _cant_r1     smallint;
define _cant_r2     smallint;
define _nombre      varchar(100);
define _numrecla    char(20);
define _date_added  date;

--set debug file to "sp_proe72.trc";
--trace on;

let _doc_comp = null; 
let _en_proceso = null; 
let _terminado = null; 

set isolation to dirty read;
	
select no_reclamo,
	   numrecla,
	   doc_completa,
	   fecha_reclamo
  into _no_reclamo,
       _numrecla,
	   _doc_completa,
	   _date_added
  from recrcmae
where no_tramite = a_tramite;

if _doc_completa = 0 then
	if year(_date_added) < 2016 then
		let _doc_comp = 'CERRADO';
	else
		let _doc_comp = 'ABIERTO';
	end if
else
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
	   and pagado = 0;
	   
 	select count(*)
	  into _cant_r2
	  from rectrmae 
	 where no_reclamo = _no_reclamo
	   and cod_tipotran = '004'
	   and cod_tipopago = '004'
	   and actualizado = 1
	   and no_requis is not null
	   and anular_nt is null
	   and pagado = 1;
	
    if _cant_r1 = 0 and _cant_r2 = 0 then	
		let _doc_comp = 'En Proceso';
	elif _cant_r1 > 0 and _cant_r2 = 0 then
		let _doc_comp = 'En Proceso';
	elif _cant_r1 = 0 and _cant_r2 > 0 then
        let _doc_comp = 'Terminado';
	end if
end if

return _numrecla, _doc_comp;

end procedure
