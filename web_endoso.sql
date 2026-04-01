
drop procedure web_endoso;
create procedure "informix".web_endoso()
returning char(10);


define _no_factura			char(10);
define a_cod_usuario		char(10);
define _no_documento		char(20);

define _error				integer;
define _error_isam			integer;
define _error_desc			char(50);
define _cantidad			integer;

begin

set isolation to dirty read;
{
foreach

	select cod_usuario
	into  a_cod_usuario
	  from	deivid_web:web_usuario
	 where	tipo_usuario  = 2
	   and status_usuario = 1
	   and cod_usuario = '00562'
 	group by cod_usuario
}

foreach
	
	select p.no_documento
	  into _no_documento
	  from emipoagt a, emipomae p
	 where a.cod_agente   in (		
'00802',
'01110',
'01122'
)
	   and a.no_poliza    = p.no_poliza
	   and p.actualizado  = 1
	   and p.no_documento is not null
  group by p.no_documento

foreach
	select no_factura
	into _no_factura
	from endedmae
	where no_documento  = _no_documento 
	and actualizado   = 1
    and prima_bruta   <> 0
    and activa        = 1
	and flag_web_corr = 1

	select	count(num_factura)
	into _cantidad
	from deivid_web:web_endoso
	where num_factura = _no_factura;

	if _cantidad = 0 then
	
		update endedmae
		set flag_web_corr = 0
		where no_factura = _no_factura
		and no_documento =  _no_documento;	 

		--return _no_factura;
	end if

end foreach
end foreach
--end foreach

end
end procedure
		