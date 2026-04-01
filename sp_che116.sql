-- Detalle de Pago para los Reclamos Legales
-- Proyecto Unificacion de los Cheques de tipo Legal

-- Creado: 16/04/2004 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_che116;

create procedure "informix".sp_che116(a_requis char(10))
returning char(100),
          char(20),
          dec(16,2),
          char(100),
          char(10),
          date,
          char(10),
          char(10);

define _nombre_aseg		char(100);
define _a_nombre_de		char(100);
define _nombre_icd		char(50);
define _no_documento	char(20);
define _numrecla		char(20);
define _cod_reclamante  char(10);
define _cod_asegurado	char(10);
define _transaccion		char(10);
define _no_reclamo		char(10);
define _no_factura		char(10);
define _no_tranrec		char(10);
define _no_requis		char(10);
define _no_cheque		char(10);
define _cod_icd			char(10);
define _cod_no_cubierto	char(3);
define _cod_chequera	char(3);
define _cod_banco		char(3);
define _facturado		dec(16,2);
define _elegible		dec(16,2);
define _pagado			dec(16,2);
define _cantidad		smallint;
define _fecha_impresion	date;
define _fecha_factura	date;

set isolation to dirty read;

select count(*)
  into _cantidad
  from chqchrec
 where no_requis = a_requis;

 if _cantidad >= 1 then
	select a_nombre_de,
		   no_requis,
		   fecha_impresion,
		   no_cheque
	  into _a_nombre_de,
		   _no_requis,
		   _fecha_impresion,
		   _no_cheque
	  from chqchmae
	 where no_requis = a_requis;


	foreach		 
		select transaccion
		  into _transaccion
		  from chqchrec
		 where no_requis = a_requis

		let _no_reclamo = "";
		let _no_tranrec = "";
		
		foreach
			select no_reclamo,
				   no_tranrec
			  into _no_reclamo,
				   _no_tranrec
			  from rectrmae
			 where transaccion = _transaccion
			   and actualizado = 1
			exit foreach;
		end foreach

		if _no_tranrec is null or _no_tranrec = "" then
			continue foreach;
		end if

		select numrecla,
			   no_documento,
			   cod_asegurado,
			   cod_reclamante
		  into _numrecla,
			   _no_documento,
			   _cod_asegurado,
			   _cod_reclamante
		  from recrcmae
		 where no_reclamo = _no_reclamo;

		select nombre
		  into _nombre_aseg
		  from cliclien
		 where cod_cliente = _cod_reclamante;

		let _cod_no_cubierto = null;

		foreach
			select cod_no_cubierto
			  into _cod_no_cubierto
			  from rectrcob
			 where no_tranrec      = _no_tranrec
			   and cod_no_cubierto is not null
			exit foreach;
		end foreach
		
		select sum(monto)
		  into _pagado
		  from rectrcob
		 where no_tranrec = _no_tranrec;
		
		return _nombre_aseg,
			   _numrecla,
			   _pagado,
			   _a_nombre_de,
			   _no_requis,
			   _fecha_impresion,
			   _no_cheque,
			   _transaccion
			   with resume;
	end foreach
end if
end procedure