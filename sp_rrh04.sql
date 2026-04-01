-- Proceso que verifica excepciones en la carga de planilla y totaliza la cantida de empleados,cheques,ach y el monto de la cuenta del banco.
-- Creado: 17/07/2012	- Autor: Roman Gordon
 													   
drop procedure sp_rrh04;

create procedure sp_rrh04(a_num_planilla char(10))
returning integer,
		  char(15),
		  date,
          char(50),
		  char(15);

define _num_ach			varchar(10);
define _descripcion		char(50);
define _comprobante		char(15);
define _usuario			char(15);
define _no_requis		char(10);
define _chequera		char(3);
define _error			smallint;
define _no_cheque		integer;
define _no_trx			integer;
define _notrx			integer;
define _fecha			date;
						
--set debug file to "sp_rrh03.trc";
--trace on;

begin

create temp table tmp_comprobantes(
notrx		integer,
comprobante	char(15),
fechatrx	date,
descripcion	char(50),
usuarioact	char(15)
) with no log;

let _comprobante	= '';
let _descripcion	= '';
let _no_requis		= '';
let _num_ach		= '';
let _no_cheque		= 0;
let _no_trx			= 0;
let _notrx			= 0;
let _chequera		= "013";

foreach
	select distinct num_ach
	  into _num_ach
	  from chqpaydet
	 where num_planilla = a_num_planilla
	   and (num_ach is not null and num_ach <> '')
	   
	foreach
		select distinct no_requis
		  into _no_requis
		  from chqchmae
		 where no_cheque	= _num_ach
		   and cod_chequera	= _chequera
		   and sac_asientos = 2
		 
		foreach
			select distinct sac_notrx
			  into _notrx
			  from chqchcta
			 where no_requis = _no_requis
			
			foreach
				select distinct res_notrx,
					   res_comprobante,
					   res_fechatrx,
					   res_descripcion,
					   res_usuarioact
				  into _no_trx,
					   _comprobante,
					   _fecha,
					   _descripcion,
					   _usuario
				  from cglresumen
				 where res_notrx = _notrx
				 
				insert into tmp_comprobantes(
						notrx,
						comprobante,
						fechatrx,
						descripcion,
						usuarioact)
				values	(_no_trx,
						_comprobante,
						_fecha,
						_descripcion,
						_usuario);
			end foreach
		end foreach
	end foreach
end foreach

foreach
	select distinct no_cheque
	  into _no_cheque
	  from chqpaydet
	 where num_planilla = a_num_planilla
	   and no_cheque <> 0
	   
	foreach
		select distinct no_requis
		  into _no_requis
		  from chqchmae
		 where no_cheque	= _no_cheque
		   and cod_chequera	= _chequera
		   and sac_asientos = 2
		 
		foreach
			select distinct sac_notrx
			  into _notrx
			  from chqchcta
			 where no_requis = _no_requis
			
			foreach
				select distinct res_notrx,
					   res_comprobante,
					   res_fechatrx,
					   res_descripcion,
					   res_usuarioact
				  into _no_trx,
					   _comprobante,
					   _fecha,
					   _descripcion,
					   _usuario
				  from cglresumen
				 where res_notrx = _notrx
				
				insert into tmp_comprobantes(
						notrx,
						comprobante,
						fechatrx,
						descripcion,
						usuarioact)
				values	(_no_trx,
						_comprobante,
						_fecha,
						_descripcion,
						_usuario);
			end foreach
		end foreach
	end foreach
end foreach

foreach
	select distinct notrx,
		   comprobante,
		   fechatrx,
		   descripcion,
		   usuarioact
	  into _no_trx,
		   _comprobante,
		   _fecha,
		   _descripcion,
		   _usuario
	  from tmp_comprobantes
	
	return _no_trx,
		   _comprobante,
		   _fecha,
		   _descripcion,
		   _usuario
		   with resume;
end foreach
drop table tmp_comprobantes;
end
end procedure