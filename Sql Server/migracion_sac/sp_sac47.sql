-- Reporte del Registro Contable de Una Poliza

-- Creado    : 13/03/2006 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_sac47;		

CREATE PROCEDURE "informix".sp_sac47(a_no_documento char(20))
returning char(10),
          char(7),
		  char(50),
		  char(25),
		  char(50),
		  dec(16,2),
		  dec(16,2),
		  smallint;

define _no_factura	char(10);
define _no_poliza	char(10);
define _no_endoso	char(5);
define _periodo		char(7);
define _cuenta		char(25);
define _debito		dec(16,2);
define _credito		dec(16,2);
define _tipo_comp	smallint;
define _nombre_cta	char(50);
define _comprobante	char(50);
define _origen		smallint;

define _no_remesa	char(10);
define _renglon		smallint;

let _origen = 1;

foreach 
 select no_poliza
   into _no_poliza
   from emipomae
  where no_documento = a_no_documento
    and actualizado  = 1

   foreach	
	select no_factura,
	       periodo,
		   no_endoso
	  into _no_factura,
	       _periodo,
		   _no_endoso
	  from endedmae
	 where no_poliza   = _no_poliza
       and actualizado = 1

	   foreach
		select cuenta,
		       debito,
			   credito,
			   tipo_comp
		  into _cuenta,
		       _debito,
			   _credito,
			   _tipo_comp
		  from endasien
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso

			let _comprobante = _tipo_comp || " - " || sp_sac11(_origen, _tipo_comp);
			 
			select cta_nombre
			  into _nombre_cta
			  from cglcuentas
			 where cta_cuenta = _cuenta;

			if _tipo_comp in (1, 2) then

				return _no_factura,
				       _periodo,
					   _comprobante,
					   _cuenta,
					   _nombre_cta,
					   _debito,
					   _credito,
					   _origen
					   with resume;

			end if

		end foreach			

	end foreach			

end foreach

let _origen = 3;
let _tipo_comp = 1;

foreach
 select no_remesa,
        renglon,
		no_recibo,
		periodo
   into _no_remesa,
        _renglon,
		_no_factura,
		_periodo
   from cobredet
  where doc_remesa  = a_no_documento
    and actualizado = 1

   foreach
	select cuenta,
	       debito,
		   credito
	  into _cuenta,
	       _debito,
		   _credito
	  from cobasien
	 where no_remesa = _no_remesa
	   and renglon   = _renglon

		let _comprobante = _tipo_comp || " - " || sp_sac11(_origen, _tipo_comp);
		 
		select cta_nombre
		  into _nombre_cta
		  from cglcuentas
		 where cta_cuenta = _cuenta;

		if _tipo_comp in (1, 2) then

			return _no_factura,
			       _periodo,
				   _comprobante,
				   _cuenta,
				   _nombre_cta,
				   _debito,
				   _credito,
				   _origen
				   with resume;

		end if

	end foreach			

end foreach

end procedure