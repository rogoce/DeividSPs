-- Detalle de Pago para los Proveedores
-- Proyecto Unificacion de los Cheques de Salud

-- Creado: 16/04/2004 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_che60;

create procedure "informix".sp_che60(a_requis char(10))
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
          char(50),
		  char(10),
		  char(10);

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
define _cod_banco		char(3);
define _cod_chequera	char(3);
define _cod_asignacion  char(10);
define _cod_entrada     char(10);
define _tipo_requis     char(1);

set isolation to dirty read;


select cod_banco,
	   cod_chequera
  into _cod_banco,
	   _cod_chequera
  from chqbanch
 where cod_ramo = '018';

	foreach
		 select	a_nombre_de,
				no_requis,
				fecha_impresion,
				no_cheque,
				tipo_requis
		   into	_a_nombre_de,
				_no_requis,
				_fecha_impresion,
				_no_cheque,
				_tipo_requis
		   from chqchmae
		  where pagado          = 1
			and anulado         = 0
			and origen_cheque   in("3","M")
			and autorizado      = 1
			and cod_banco	    = _cod_banco
			and cod_chequera    = _cod_chequera
			and en_firma        = 2
			and no_requis       = a_requis

		--	and fecha_impresion = today
			let _no_requis = trim(_no_requis);

			delete from recunino
			 where no_requis = _no_requis;

			 select count(*)
			   into _cantidad
			   from chqchrec
			  where no_requis = _no_requis;

			foreach
			 
			 select transaccion
			   into _transaccion
			   from chqchrec
			  where no_requis = _no_requis

		--	    and monto     > 0

			   let _no_reclamo = "";
			   let _no_tranrec = "";
			   let _no_factura = "";
			   let _cod_asignacion = null;
			   let _cod_entrada = null;
			   
			   foreach
					select no_reclamo,
						   no_tranrec,
						   no_factura,
						   fecha_factura,
						   cod_asignacion
					  into _no_reclamo,
						   _no_tranrec,
						   _no_factura,
						   _fecha_factura,
						   _cod_asignacion
					  from rectrmae
					 where transaccion = _transaccion
					   and actualizado = 1
					exit foreach;
			   end foreach

				if _no_tranrec is null or _no_tranrec = "" then
					continue foreach;
				end if
				
				if _cod_asignacion is not null and trim(_cod_asignacion) <> "" then
					select cod_entrada
					  into _cod_entrada
					  from atcdocde
					 where cod_asignacion = _cod_asignacion;
				end if		

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
					   _nombre_icd,
					   _cod_entrada,
					   case when _tipo_requis = 'A' then 'ACH' else 'Cheque' end 
					   with resume;
			end foreach
	end foreach
end procedure