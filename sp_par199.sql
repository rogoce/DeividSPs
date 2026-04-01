
create procedure sp_par199()
returning char(20), 
          char(50),
		  char(50),
		  char(50);

define _no_documento	char(20);
define _no_poliza		char(10);
define _nombre_ase		char(50);
define _nombre_agt		char(50);
define _nombre_gru		char(50);
define _cod_grupo		char(5);
define _accionista		smallint;
define _cod_agente		char(5);
define _cod_cliente		char(10);

set isolation to dirty read;

foreach
 select	no_documento
   into	_no_documento
   from	emipoliza

	let _no_poliza = sp_sis21(_no_documento);

	select cod_grupo,
	 	   cod_contratante
	  into _cod_grupo,
	       _cod_cliente
	  from emipomae
	 where no_poliza = _no_poliza;

	select accionista,
	       nombre
	  into _accionista,
	       _nombre_gru
	  from cligrupo
	 where cod_grupo = _cod_grupo;

	if _accionista = 1 then
		continue foreach;
	end if

	foreach
	 select cod_agente
	   into _cod_agente
	   from emipoagt
	  where no_poliza  = _no_poliza
		and cod_agente in ("00081", "00063", "00726", "00064", "00874", "00716", "00036", " 00370")

		select nombre
		  into _nombre_agt
		  from agtagent
		 where cod_agente = _cod_agente;

		select nombre
		  into _nombre_ase
		  from cliclien
		 where cod_cliente = _cod_cliente;

		return _no_documento,
		       _nombre_ase,
			   _nombre_gru,
			   _nombre_agt
			   with resume;

	end foreach

end foreach

end procedure
