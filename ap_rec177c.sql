--Procedimiento que verifica las reservas de reclamos de un periodo vs el periodo anterior 
-- Creado     :	04/12/2010 - Autor: Demetrio Hurtado Almanza
-- SIS v.2.0 - DEIVID, S.A.

drop procedure ap_rec177c;		

create procedure "informix".ap_rec177c()
returning	integer,	--flag	(1- Diferencia en Cobertura, 2- Diferencia en Totales)
			char(50),	--_numrecla
			char(10),	--_no_reclamo
			dec(16,2),	--_reserva_actual
			dec(16,2);	--_variacion

define _error_desc		char(50);
define _numrecla		char(18);
define _no_reclamo		char(10);
define _cod_cober_rec	char(5);
define _cod_cobertura	char(5);
define _res_actual_rcob	dec(16,2);
define _reserva_actual	dec(16,2);
define _variacion_cob	dec(16,2);
define _variacion_ac	dec(16,2);
define _variacion_tr	dec(16,2);
define _error			integer;
define _error_isam		integer;

--set debug file to "sp_rec177c.trc";
--trace on;

set isolation to dirty read;

begin
on exception set _error,_error_isam,_error_desc
	drop table tmp_verif;
 	return _error,_error_desc,_no_reclamo,0.00,0.00;       
end exception

create temp table tmp_verif(
	no_reclamo			char(10)  not null,
	cod_cobertura		char(5) not null,
	reserva_actual_r	dec(16,2) not null,
	--reserva_inicial_r	dec(16,2) not null,
	reserva_actual		dec(16,2) not null,
	--reserva_inicial		dec(16,2) not null,
primary key (no_reclamo,cod_cobertura)) with no log;

let _res_actual_rcob = 0.00;
let _reserva_actual = 0.00;
let _variacion_cob = 0.00;
let _variacion_tr = 0.00;
let _no_reclamo = '';
let _numrecla = '';

foreach
	select numrecla
	  into _numrecla
	  from tmp_exceso_reserva
	 where seleccionado = 1
	
	select no_reclamo,
--		   res_inicial_rec
		   reserva_actual
	  into _no_reclamo,
--		   _reserva_inicial,
		   _reserva_actual
	  from recrcmae
	 where numrecla = _numrecla;
	
	if _no_reclamo is null or _no_reclamo = '' or _no_reclamo in ('316830','316901','315455','316635','316032','304117','312947','313077')then
		continue foreach;
	end if
	
	foreach
		select cod_cobertura,
			   sum(reserva_actual)
		  into _cod_cober_rec,
			   _res_actual_rcob
		  from recrccob
		 where no_reclamo = _no_reclamo
		 group by 1
		
		insert into tmp_verif
		values(	_no_reclamo,
				_cod_cober_rec,
				_reserva_actual,
				_res_actual_rcob);
	end foreach
	
	select sum(variacion)
	  into _variacion_tr
	  from rectrmae
	 where no_reclamo = _no_reclamo
	   and actualizado = 1;
	
	let _variacion_ac = 0.00;
	
	foreach
		select cod_cobertura,
			   sum(c.variacion)
		  into _cod_cobertura,
			   _variacion_cob
		  from rectrmae tr, rectrcob c
		 where tr.no_tranrec = c.no_tranrec
		   and tr.no_reclamo = _no_reclamo
		   and tr.actualizado = 1
		 group by 1
		
		let _variacion_ac = _variacion_ac + _variacion_cob;
		let _reserva_actual = 0.00;
		let _res_actual_rcob = 0.00;
		
		select reserva_actual_r,
			   reserva_actual
		  into _reserva_actual,
			   _res_actual_rcob
		  from tmp_verif
		 where no_reclamo = _no_reclamo
		   and cod_cobertura = _cod_cobertura;
		
		if _reserva_actual is null then
			let _reserva_actual = 0.00;
		end if
		
		if _res_actual_rcob is null then
			let _res_actual_rcob = 0.00;
		end if
		
		if _variacion_cob <> _res_actual_rcob then
			update recrccob
			   set reserva_actual = _variacion_cob
			 where no_reclamo = _no_reclamo
			   and cod_cobertura = _cod_cobertura;
			   
			return 1,_numrecla,_no_reclamo,_res_actual_rcob,_variacion_cob with resume;
		end if
	end foreach
	
	select reserva_actual
	  into _reserva_actual
	  from recrcmae
	 where numrecla = _numrecla;
	
	if _reserva_actual <> _variacion_tr then
		{update recrcmae
		   set reserva_actual = _variacion_tr
		 where no_reclamo = _no_reclamo;}
		return 2,_numrecla,_no_reclamo,_variacion_ac,_variacion_tr with resume;
	end if
end foreach

--return 0,'Modificación Exitosa';
drop table tmp_verif;
end
end procedure
