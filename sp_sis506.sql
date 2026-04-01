-- Procedimiento que genera el código html del proceso de correos masivo
-- Creado    :05/04/2018 - Autor: Amado Perez
drop procedure sp_sis506;
create procedure "informix".sp_sis506(a_secuencia integer, a_codigo varchar(50))
returning char(3000);

define _html			    char(3000);
define _html2			    char(3000);
define _fecha_completa	    varchar(60);
define _doc_electronico	    varchar(30);
define _nom_cliente		    varchar(50);
define _cod_pagador		    varchar(30);
define _no_documento	    varchar(20);
define _no_poliza		    char(10);
define _cod_tipo		    char(5);
define _fecha        		date;
define _fecha_rechazo		date;
define _fecha_suspension    date;
define _fecha_cancelacion   date;  
define _exigible	        dec(10,2);
define _exigible2           varchar(10);
define _fecha_suspension2   varchar(10);
define _fecha_cancelacion2  varchar(10);
define _monto               dec(16,2);
define _monto2              varchar(10);
define _fecha2              varchar(10);
define _fecha_letra         varchar(50);
define _no_remesa           char(10);

set isolation to dirty read;

begin


--set debug file to "sp_sis506.trc";      
--trace on;

select cod_tipo
  into _cod_tipo
  from parmailsend
 where secuencia = a_secuencia;

select trim(html)
  into _html
  from parmailtipo
 where cod_tipo = _cod_tipo;

foreach
	select trim(no_documento),
		   asegurado,
		   fecha,
		   saldo,
		   no_remesa
	  into _no_documento,
		   _cod_pagador,
		   _fecha_suspension,
		   _exigible,
		   _no_remesa
	  from parmailcomp
	 where mail_secuencia = a_secuencia
	exit foreach;
end foreach  

let _exigible2 = _exigible;

select trim(nombre)
  into _nom_cliente
  from cliclien
 where cod_cliente = _cod_pagador;

if _cod_tipo in ('00021','00023') then --Notificaciones de Rechazos TCR/ACH
	
	let _fecha_rechazo = _fecha_suspension;
	let _doc_electronico = _cod_pagador;
	let _cod_pagador = '';

	if _cod_tipo = '00021' then
		let _no_poliza = sp_sis21(_no_documento);

		select cod_pagador
		  into _cod_pagador
		  from emipomae
		 where no_poliza = _no_poliza;

		select nombre
		  into _nom_cliente
		  from cliclien
		 where cod_cliente = _cod_pagador;
	else
		select nombre_pagador
		  into _nom_cliente
		  from cobcutmpre
		 where no_cuenta = _doc_electronico
		   and no_documento = _no_documento
		   and date(date_added) = _fecha_rechazo;
	end if
	
	let _html = replace(trim(_html),'%_pagador%',_nom_cliente);

elif _cod_tipo in ('00039') then
	let _fecha_completa = sp_sis20(_fecha_suspension);
	let _html = replace(trim(_html),'%_fecha_completa%',_fecha_completa);
	let _html = replace(trim(_html),'%_pagador%',_nom_cliente);
	let _html = replace(trim(_html),'%_no_documento%',trim(_no_documento));
	let _html = replace(trim(_html),'%_exigible%',trim(_exigible2));
	
	
elif _cod_tipo in ('00037','00038') then --Notificaciones de Suspensión de Cobertura
 
	if _fecha_suspension is null then
		return '';
	end if

	let _fecha_cancelacion = _fecha_suspension + 60 units day;
	let _fecha_suspension2 = _fecha_suspension;
	let _fecha_cancelacion2 = _fecha_cancelacion;

	let _html = replace(trim(_html),'%_pagador%',_nom_cliente);
	let _html = replace(trim(_html),'%_no_documento%',trim(_no_documento));
	let _html = replace(trim(_html),'%_exigible%',trim(_exigible2));
	let _html = replace(trim(_html),'%_fecha_suspension%',trim(_fecha_suspension2));
	let _html = replace(trim(_html),'%_fecha_cancelacion%',trim(_fecha_cancelacion2));
elif _cod_tipo = '00016' then
	call sp_che126(a_secuencia) returning _nom_cliente, _monto, _fecha;
    let _monto2 = _monto;
	
    let _fecha_letra = sp_fecha_letra(_fecha);
	
    let _html = replace(trim(_html),'%_fecha%',trim(upper(_fecha_letra)));	
    let _html = replace(trim(_html),'%_nombre%',trim(_nom_cliente));	
    let _html = replace(trim(_html),'%_monto%',trim(_monto2));	
elif _cod_tipo = '00019' then
    select nombre
	  into _nom_cliente
	  from agtagent
	 where cod_agente = _no_remesa;
	 
    let _html = replace(trim(_html),'%_nombre%',trim(_nom_cliente));	
    let _html = replace(trim(_html),'%_codigo%','360001501990='||trim(a_codigo));	
end if

return trim(_html);

end
end procedure;