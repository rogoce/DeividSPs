-- Detalle de Pago para los Proveedores
-- Proyecto Unificacion de los Cheques de Salud

-- Creado: 16/04/2004 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_rec80;

create procedure "informix".sp_rec80(a_no_cheque integer, a_no_requis char(10) default "%")
returning char(100),
          char(20),
          char(20),
          date,
          dec(16,2),
          dec(16,2),
          dec(16,2),
          char(100),
          char(10),
          date,
          char(10),
          char(10),
          char(10),
          char(3),
          char(50);

define _a_nombre_de		char(100);
define _no_requis		char(10);
define _fecha_impresion	date;
define _transaccion		char(10);
define _no_reclamo		char(10);
define _numrecla		char(20);
define _no_documento	char(20);
define _fecha_factura	date;
define _cod_asegurado	char(10);
define _nombre_aseg		char(100);
define _facturado		dec(16,2);
define _elegible		dec(16,2);
define _pagado			dec(16,2);
define _no_tranrec		char(10);
define _no_cheque		char(10);
define _no_factura		char(10);
define _cod_no_cubierto	char(3);
define _cod_icd			char(10);
define _cod_reclamante  char(10);
define _nombre_icd		char(50);
define _cantidad		smallint;

set isolation to dirty read;

foreach
 select	a_nombre_de,
        no_requis,
		fecha_impresion,
		no_cheque
   into	_a_nombre_de,
        _no_requis,
		_fecha_impresion,
		_no_cheque
   from chqchmae
  where cod_banco       = '001'
    and cod_chequera    = '006'
    and pagado          = 1
    and anulado         = 0
	--and origen_cheque   = "3"
	and origen_cheque in("3","M")
	and no_cheque       = a_no_cheque
	and no_requis       like a_no_requis

	delete from recunino
	 where no_requis = _no_requis;

	 select count(*)
	   into _cantidad
	   from chqchrec
	  where no_requis = _no_requis;

{	if _cantidad = 1 then
		continue foreach;
	end if}

	foreach 
	 select transaccion
	   into _transaccion
	   from chqchrec
	  where no_requis = _no_requis

		select no_reclamo,
		       no_tranrec,
			   no_factura,
			   fecha_factura
		  into _no_reclamo,
			   _no_tranrec,
			   _no_factura,
			   _fecha_factura
		  from rectrmae
		 where transaccion = _transaccion;

		select numrecla,
		       no_documento,
			   cod_asegurado,
			   cod_icd,
			   cod_reclamante
		  into _numrecla,
		       _no_documento,
			   _cod_asegurado,
			   _cod_icd,
			   _cod_reclamante
		  from recrcmae
		 where no_reclamo = _no_reclamo;

		select nombre
		  into _nombre_icd
		  from recicd
		 where cod_icd = _cod_icd;

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

		if _cod_no_cubierto is not null then
			insert into recunino
			values (_no_requis, _cod_no_cubierto);
		end if
	
		select sum(facturado),
		       sum(elegible),
			   sum(monto)
		  into _facturado,
		       _elegible,
			   _pagado
		  from rectrcob
		 where no_tranrec = _no_tranrec;
	
		return _nombre_aseg,
		       _numrecla,
		       _no_documento,
		       _fecha_factura,
		       _facturado,
		       _elegible,
		       _pagado,
		       _a_nombre_de,
		       _no_requis,
		       _fecha_impresion,
		       _no_cheque,
		       _transaccion,
		       _no_factura,
		       _cod_no_cubierto,
		       _nombre_icd
			   with resume;

	end foreach

end foreach

end procedure