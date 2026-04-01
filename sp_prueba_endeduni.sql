-- Envios masivos de correos por prioridad de envio
-- Creado por :    Roman Gordon		 08/04/2011
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_prueba_endeduni;

create procedure "informix".sp_prueba_endeduni() 
returning	char(10),
			char(20),
			char(5),
			date;  --  
		   		  	

define _html_body		char(512);
define _asunto			char(100);
define _asunto_orig		char(100);
define _email			char(250);
define _sender_send		char(100);
define _sender_tipo		char(50);
define _ruta_image		char(50);
define _nombre_cliente	char(50);
define _nombre_agente	char(50);
define _no_documento	char(20);
define _enviado			char(20);
define _no_tarjeta		char(19);
define _no_cuenta		char(17);
define _cod_cliente		char(10);
define _no_poliza		char(10);
define _no_lote			char(5);
define _no_unidad		char(5);
define _no_endoso		char(5);
define _tipo_tran		char(1);
define _secuencia		integer;
define _adjunto			smallint;
define _renglon			smallint;
define _cnt_endeduni	smallint;
define _cnt_tcr			smallint;
define _bandera  		smallint;
define _cnt_rechazo		smallint;
define _nombre_agente2	char(255);
define _no_documento2	char(255);
define _date_added		date;

set isolation to dirty read;

--set debug file to "sp_prueba_endeduni.trc";
--trace on;

foreach
	select no_poliza,
		   no_endoso,
		   no_documento,
		   date_added
	  into _no_poliza,
		   _no_endoso,
		   _no_documento,
		   _date_added
	  from endedmae 
	 where cod_endomov = '003' 
	   and vigencia_inic=vigencia_final 
	   and actualizado = 1 
	   and date_added > '01/01/2011' 
	 order by date_added

	select count(*)
	  into _cnt_endeduni
	  from endeduni
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;

	if _cnt_endeduni > 0 then
		return _no_poliza,_no_documento,_no_endoso,_date_added with resume;
	end if
end foreach
return '','','','01/01/1900';
end procedure