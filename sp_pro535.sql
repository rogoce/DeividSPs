-- Reporte de Pronto Pago para Autos Suntracs

-- Creado:	24/09/2013	Demetrio Hurtado Almanza

drop procedure sp_pro535;

create procedure "informix".sp_pro535()
returning char(20),
          dec(16,2),
		  char(50),
		  char(50),
		  smallint,
		  char(50);

define _no_documento	char(20);
define _prima_bruta		dec(16,2);
define _cod_formapag	char(3);
define _nom_formapag	char(50);
define _cod_grupo		char(5);
define _nom_grupo		char(50);
define _cantidad		smallint;
define _cod_agente		char(5);
define _nom_agente		char(50);
define _no_poliza		char(10);

foreach
 select no_documento,
        prima_bruta,
		cod_formapag,
		cod_grupo,
		no_poliza
   into _no_documento,
        _prima_bruta,
		_cod_formapag,
		_cod_grupo,
		_no_poliza
   from emipomae
  where actualizado = 1
    and cod_ramo    = "002"
	and cod_grupo   = "01016"

	select nombre
	  into _nom_formapag
	  from cobforpa
	 where cod_formapag = _cod_formapag;

	select nombre
	  into _nom_grupo
	  from cligrupo
	 where cod_grupo = _cod_grupo;

	select count(*)
	  into _cantidad
	  from endedmae
	 where no_poliza	= _no_poliza
	   and cod_endomov	= '024'
	   and actualizado  = 1;

	foreach
	 select cod_agente
	   into _cod_agente
	   from emipoagt
	  where no_poliza  = _no_poliza
	    and cod_agente IN ("00180", "00169") 

		select nombre
		  into _nom_agente
		  from agtagent
		 where cod_agente = _cod_agente;

		return _no_documento,
		       _prima_bruta,
			   _nom_formapag,
			   _nom_grupo,
			   _cantidad,
			   _nom_agente
			   with resume;

	end foreach

end foreach

end procedure