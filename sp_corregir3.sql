-- Procedure que determina cuales facturas han cambiado
-- desde que se crearon

-- Creado    : 31/07/2002 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 31/07/2002 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_corregir3;

create procedure sp_corregir3()
returning char(10),
		  char(20),
		  char(3),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2);

define _no_poliza		  char(10);
define _no_documento      char(20);
define _cod_impuesto      char(3);
define _cnt				  integer;
define _monto             dec(16,2);
define _prima_bruta       dec(16,2);
define _impuesto       dec(16,2);
define _imp       dec(16,2);


let _cnt = 0;
let _monto = 0;
let _prima_bruta = 0;
let _impuesto = 0;

set isolation to dirty read;


{foreach

	select e.no_poliza
	  into _no_poliza
	from emirepo e, emideren t
	where e.no_poliza = t.no_poliza
	and t.renglon = 9
	and e.user_added = 'SLEE'

	update emirepo
	set user_added = 'AHILL'
	where no_poliza = _no_poliza;

end foreach}

{foreach
	select no_poliza
	  into _no_poliza
	 from cobaviso
	where cod_cobrador = '151'
	and tipo_aviso = 1
	and impreso = 1

	update emipomae
	   set fecha_aviso_canc = today,
	       carta_aviso_canc = 1
	 where no_poliza = _no_poliza;

end foreach}

foreach

	select no_poliza,
	       no_documento,
		   prima_neta,
		   impuesto
	  into _no_poliza,
	       _no_documento,
		   _prima_bruta,
		   _impuesto
	  from emipomae
	 where actualizado = 1
	   and no_documento[12,13] = '09'

		select count(*)
		  into _cnt
		  from endedimp
		 where no_poliza = _no_poliza
		   and no_endoso = '00000';

		if _cnt > 1 then

			continue foreach;

		else

		  	select cod_impuesto,
			       monto
			  into _cod_impuesto,
			       _monto
			  from endedimp
			 where no_poliza = _no_poliza
			   and no_endoso = '00000';

			let _imp = 0;
			let _imp = _prima_bruta * 0.01;

		 { 	INSERT INTO endedimp(
			no_poliza,
			no_endoso,
			cod_impuesto,
			monto
			)
			VALUES(
			_no_poliza,
			"00000",
			"002",
			_imp
			);	}

		
			RETURN _no_poliza,
				   _no_documento,
				   _cod_impuesto,
				   _monto,
				   _prima_bruta,
				   _impuesto,
				   _imp
				WITH RESUME;

	    end if

end foreach


end procedure

