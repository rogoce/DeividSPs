drop procedure sp_cas070;

create procedure sp_cas070()
returning char(3),
          char(20),
		  date,
		  date,
		  char(10),
		  char(50);

define _no_documento	char(20);
define _no_poliza		char(10);
define _cod_cobrador	char(10);
define _vigencia_inic	date;
define _vigencia_final	date;
define _cod_cliente		char(10);
define _nombre_cob		char(50);

foreach
 select c.no_documento,
        m.cod_cobrador,
		m.cod_cliente
   into _no_documento,
        _cod_cobrador,
		_cod_cliente
   from caspoliza c, cascliente m
  where c.cod_cliente = m.cod_cliente
    and m.cod_cobrador in ('006','031','044')
  order by m.cod_cobrador

	let _no_poliza = sp_sis21(_no_documento);

	select vigencia_final,
	       vigencia_inic
	  into _vigencia_final,
	       _vigencia_inic
	  from emipomae
	 where no_poliza = _no_poliza;

	if _vigencia_final < "01/06/2003" then

		select nombre
		  into _nombre_cob
		  from cobcobra
		 where cod_cobrador = _cod_cobrador;

		return _cod_cobrador,
		       _no_documento,
		       _vigencia_inic,
		       _vigencia_final,
			   _cod_cliente,
			   _nombre_cob
		       with resume;		

	end if
	
	
end foreach


end procedure