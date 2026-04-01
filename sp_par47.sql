-- Verificacion de No Documento Vs No Poliza
-- en la Captura de Remesas

drop procedure sp_par47();

create procedure sp_par47()
returning char(10),
		  char(7),
		  date,
		  smallint,
		  char(10),
		  char(20),
		  char(20),
		  char(10),
		  smallint,
		  char(10);
		  	
define _no_doc_rem	char(20);
define _no_doc_pol	char(20);
define _no_poliza	char(10);

define _no_remesa	char(10);
define _periodo		char(7);
define _fecha		date;
define _actualizado	smallint;
define _no_recibo	char(10);
define _renglon		smallint;
define _no_poliza_2	char(10);

foreach
 select no_poliza,
		doc_remesa,
		no_remesa,
		periodo,
		fecha,
		actualizado,
		no_recibo,
		renglon
   into _no_poliza,
		_no_doc_rem,
		_no_remesa,
		_periodo,
		_fecha,
		_actualizado,
		_no_recibo,
		_renglon
   from cobredet
  where tipo_mov IN ('P', 'N')
  order by periodo desc, fecha desc
  	
	select no_documento
	  into _no_doc_pol
	  from emipomae
	 where no_poliza = _no_poliza;
	 
	if _no_doc_rem <> _no_doc_pol then

		let _no_poliza_2 = sp_sis21(_no_doc_rem);

		return _no_remesa,
			   _periodo,
			   _fecha,
			   _actualizado,
			   _no_poliza,
			   _no_doc_rem,
			   _no_doc_pol,
			   _no_recibo,
			   _renglon,
			   _no_poliza_2
			   with resume;	
	end if 	

end foreach

end procedure
