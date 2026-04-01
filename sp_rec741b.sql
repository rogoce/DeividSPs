-- Procedimiento que busca detalle de parmailcomp

-- Creado    : 07/11/2017 - Autor: Amado Perez
-- Copia del sp_che67

 drop procedure sp_rec741b;

 create procedure sp_rec741b(a_mail_secuencia integer)
 returning dec(16,2), integer, varchar(100);

define _a_nombre_de		varchar(100);
define _no_tranrec		char(10);
define _monto_tot		dec(16,2);
define _monto_rec       dec(16,2);
define _ano_cal         integer;
define _no_reclamo      char(10);
define _no_poliza       char(10);
define _no_unidad       char(5);
define _fecha_factura   date;
define _cod_reclamante  char(10);
define _vigencia_inic   date;
define _reemplaza_poliza char(20);
define _no_endoso       char(5);
define _no_endoso_r     char(5);
define _no_poliza_r     char(10);
define _cod_producto    char(5);
define _tipo_acum_deduc smallint;
define _ano_cal_int     integer;
define _descripcion     char(255);
define _numrecla        char(20);
define _transaccion     char(10);
define _error           integer;

set isolation to dirty read;

create temp table tmp_ded_agno (
    cod_reclamante char(10),
	nombre varchar(100),
	agno integer,
	deducible dec(16,2),
	primary key (cod_reclamante, agno)) with no log;

let _monto_tot = 0;
let _monto_rec = 0;
let _ano_cal = null;

foreach
	select no_remesa
	  into _no_tranrec
	  from parmailcomp
	 where mail_secuencia = a_mail_secuencia
	group by no_remesa

	select no_reclamo,
	       fecha_factura,
		   transaccion
   	  into _no_reclamo,
	       _fecha_factura,
		   _transaccion
	  from rectrmae
	 where no_tranrec = _no_tranrec;
	 
	select cod_reclamante,
	       no_poliza,
		   no_unidad,
		   numrecla
	  into _cod_reclamante,
	       _no_poliza,
		   _no_unidad,
		   _numrecla
	  from recrcmae
	 where no_reclamo = _no_reclamo;
	 
	select nombre
	  into _a_nombre_de
	  from cliclien
	 where cod_cliente = _cod_reclamante;
	 
	select sum(a_deducible)
	  into _monto_rec
	  from rectrcob
	 where no_tranrec = _no_tranrec;
			 
	select vigencia_inic,
		   reemplaza_poliza
	  into _vigencia_inic,
		   _reemplaza_poliza
	  from emipomae
	 where no_poliza = _no_poliza;

	let _no_endoso = null;
	let _no_endoso_r = null;

	foreach
		select no_endoso
		  into _no_endoso
		  from endedmae
		 where no_poliza = _no_poliza
		   and vigencia_inic <= _fecha_factura
		   and vigencia_final > _fecha_factura
		   and cod_endomov = '014'
	end foreach

	if _no_endoso is null then 
		if _reemplaza_poliza is not null and trim(_reemplaza_poliza) <> "" then
			select no_poliza 
			  into _no_poliza_r
			  from emipomae
			 where no_documento = _reemplaza_poliza;
			 
			foreach
				select no_endoso
				  into _no_endoso_r
				  from endedmae
				 where no_poliza = _no_poliza_r
				   and vigencia_inic >= _fecha_factura
				   and vigencia_final < _fecha_factura
				   and cod_endomov = '014'
			end foreach
			
			if _no_endoso_r is null then
				select cod_producto
				  into _cod_producto
				  from emipouni
				 where no_poliza = _no_poliza
				   and no_unidad = _no_unidad;
			else
				select cod_producto
				  into _cod_producto
				  from endeduni
				 where no_poliza = _no_poliza_r
				   and no_endoso = _no_endoso_r
				   and no_unidad = _no_unidad;		
			end if
			   
		else
			select cod_producto
			  into _cod_producto
			  from emipouni
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad;
		end if
	else
		select cod_producto
		  into _cod_producto
		  from endeduni
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso
		   and no_unidad = _no_unidad;
	end if

	if _cod_producto is null then
		foreach	
			select u.cod_producto
			  into _cod_producto
			  from endeduni	u, endedmae e
			 where u.no_poliza   = _no_poliza
			   and u.no_unidad   = _no_unidad
			   and u.no_poliza   = e.no_poliza
			   and u.no_endoso   = e.no_endoso
			   and e.actualizado = 1
			exit foreach;
		end foreach
	end if

	select tipo_acum_deduc
	  into _tipo_acum_deduc
	  from prdprod
	 where cod_producto = _cod_producto;

	let _ano_cal = year(_fecha_factura);

	--Verificación de Deducible por Año Póliza
	if _tipo_acum_deduc = 2 then
		if month(_vigencia_inic) > month(_fecha_factura) then		
			let _ano_cal_int = _ano_cal;
			let _ano_cal_int = _ano_cal_int - 1;
			let _ano_cal = _ano_cal_int;
		elif month(_vigencia_inic) = month(_fecha_factura) then
			if day(_vigencia_inic) > day(_fecha_factura) then
				let _ano_cal_int = _ano_cal;
				let _ano_cal_int = _ano_cal_int - 1;
				let _ano_cal = _ano_cal_int;
			end if
		end if
	end if		
	begin
	on exception set _error 

		if _error = -268 or _error = -239 then 
			update tmp_ded_agno 
			   set deducible = deducible + _monto_rec
			 where cod_reclamante = _cod_reclamante 
			   and agno = _ano_cal;
		end if
	end exception	
	
	insert into tmp_ded_agno values(
	   _cod_reclamante,
	   _a_nombre_de,
	   _ano_cal,
	   _monto_rec);
	end 
	 	
 end foreach

 foreach with hold
	select nombre,
	       agno,
		   deducible
	  into _a_nombre_de,
	       _ano_cal,
		   _monto_tot
	  from tmp_ded_agno
	 order by 1, 2
	  
	  return _monto_tot, _ano_cal, _a_nombre_de with resume;
 end foreach

drop table tmp_ded_agno;
end procedure
