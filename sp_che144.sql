-- Reporte de los cheques de devolucion de primas en coaseguro mayoritario

-- Creado    : 01/10/2013 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 -- -- DEIVID, S.A.

drop procedure sp_che144;

create procedure sp_che144()
returning char(10),
          date,
		  char(50),
		  char(20),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  char(50),
		  dec(16,2);

define _no_requis		char(10);
define _no_poliza		char(10);
define _cod_tipoprod	char(3);
define _fecha			date;
define _a_nombre_de		char(50);
define _no_documento	char(20);
define _monto			dec(16,2);
define _prima_neta		dec(16,2);
define _cod_coasegur	dec(3);
define _nom_coasegur	char(50);
define _porc_partic_coas	dec(16,2);

define _impuesto_5		dec(16,2);
define _impuesto_1		dec(16,2);
define _cantidad		integer;

foreach
 select	no_requis,
        fecha_impresion,
		a_nombre_de
   into	_no_requis,
        _fecha,
		_a_nombre_de
   from chqchmae
  where	origen_cheque = "6"
    and pagado        = 1
	and anulado       = 0
	and year(fecha_impresion) >= 2008
  order by fecha_impresion

	foreach
	 select	no_poliza,
	        no_documento,
			monto,
			prima_neta
	   into	_no_poliza,
	        _no_documento,
	        _monto,
	        _prima_neta    
	   from	chqchpol
	  where	no_requis = _no_requis

		select cod_tipoprod
		  into _cod_tipoprod
		  from emipomae
		 where no_poliza = _no_poliza;

		if _cod_tipoprod = "001" then

			select sum(debito - credito)
			  into _impuesto_5
			  from chqchcta
			 where no_requis = _no_requis
			   and no_poliza = _no_poliza
			   and cuenta    in ("26503", "26501");
	
			select sum(debito - credito)
			  into _impuesto_1
			  from chqchcta
			 where no_requis = _no_requis
			   and no_poliza = _no_poliza
			   and cuenta    = "26504";

			{
			if _impuesto_5 is not null or 
			   _impuesto_1 is not null then
				continue foreach;
			end if

			select count(*)
			  into _cantidad
			  from chqchcta
			 where no_requis = _no_requis
			   and no_poliza is null;

			if _cantidad = 0 then
				continue foreach;
			end if
			}

			return _no_requis,
			       _fecha,
				   _a_nombre_de,
				   _no_documento,
				   _monto,
				   _prima_neta,
				   _impuesto_5,
				   _impuesto_1,
				   null,
				   null
				   with resume;

			foreach
			 select cod_coasegur,
					porc_partic_coas
			   into _cod_coasegur,
			        _porc_partic_coas
			   from emicoama
			  where no_poliza = _no_poliza

				select nombre
				  into _nom_coasegur 
				  from emicoase
				 where cod_coasegur = _cod_coasegur;

					return _no_requis,
					       null,
						   null,
						   _no_documento,
						   null,
						   null,
						   null,
						   null,
						   _nom_coasegur,
						   _porc_partic_coas
						   with resume;

			end foreach
			
		end if

	end foreach

end foreach

end procedure
