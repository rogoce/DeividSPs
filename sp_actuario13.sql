-- DROP procedure sp_actuario13;

 CREATE procedure "informix".sp_actuario13()
   RETURNING date,	   
   			 char(20), 
 			 char(30), 
			 char(50),
			 smallint, 
			 char(25),
			 DEC(16,2),
			 DEC(16,2),
			 DEC(16,2),
			 DEC(16,2),
			 CHAR(7);

 BEGIN

    define v_no_poliza        CHAR(10);
    define _cod_cliente       CHAR(10);
    define _recibi_de         CHAR(50);
    define _f_recibo     	  DATE;
	define _no_factura        char(10);
	define _estatus_char      char(12);
	define _no_recibo		char(20);
	define _no_remesa		char(30);
	define _prima_neta		DEC(16,2);
	define _impuesto     	DEC(16,2);
	define _fecha_suscripcion DATE;
	define _valor integer;
	define _renglon smallint;
	define _cuenta  char(25);
	define _debito  DEC(16,2);
	define _credito DEC(16,2);
	define _periodo char(7); 

SET ISOLATION TO DIRTY READ; 

CALL verifica('001','001','1800-00035-01') RETURNING _valor;

foreach

	select fecha,
	       no_documento,
		   tipo_fac
	  into _f_recibo,
	       _no_recibo,
		   _no_remesa
	  from tmp_sa
	 where referencia <> 'FACTURA'
	 and periodo between '2009-01' and '2009-12'
	 order by fecha desc

   foreach
	select recibi_de
	  into _recibi_de
	  from cobremae
	 where no_remesa = _no_remesa
	exit foreach;
   end foreach

	foreach

		select renglon,
		       cuenta,
			   debito,
			   credito,
			   periodo
		  into _renglon,
		       _cuenta,
		       _debito,
		       _credito ,
			   _periodo
		  from cobasien
		 where no_remesa = _no_remesa
		 order by renglon

	   foreach
		select impuesto,
		       prima_neta
		  into _impuesto,
		       _prima_neta
		  from cobredet
		 where no_remesa = _no_remesa
		   and renglon   = _renglon

			exit foreach;
	   end foreach

	  return _f_recibo,
			 _no_recibo,
			 _no_remesa,
			 _recibi_de,
			 _renglon,
			 _cuenta,
			 _debito,
			 _credito,
			 _prima_neta,
			 _impuesto,
			 _periodo
	   with resume;


	end foreach

end foreach

DROP TABLE tmp_sa;

END

END PROCEDURE;
