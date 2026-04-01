--Procedimiento que arregla los montos de pagos por coberturas.
 
-- Creado     :	03/10/2019 - Autor: Armando Moreno M.

-- a_valor	(0 - Reporte diferencias, 	1 - Actualiza en RECRCCOB)

drop procedure ap_rec177dd;
create procedure ap_rec177dd(a_valor smallint default 0, a_periodo char(7))
returning	smallint,
			char(18),
			char(3),
			dec(16,2),
			dec(16,2);

define _no_reclamo		    char(10);
define _numrecla            char(18);
define _cod_cobertura	    char(5);
define _monto_tr,_pagos_rec	dec(16,2);
define _n_cob               char(3);

--set debug file to "sp_rec177c.trc";
--trace on;

set isolation to dirty read;

begin
let _n_cob = '';
let _monto_tr = 0.00;
let _no_reclamo = '';


foreach
		select distinct numrecla
		  into _numrecla
		  from rectrmae
		 where actualizado = 1
		   and periodo = a_periodo
		   and numrecla[1,2] in('02','20','23')
		{select numrecla
		  into _numrecla
		  from deivid_tmp:aud_pag}
	  
		select no_reclamo
		  into _no_reclamo
		  from recrcmae
		 where numrecla = _numrecla;
		 
		foreach
			select r.cod_cobertura,
				   sum(r.monto)
			  into _cod_cobertura,
				   _monto_tr			   
			  from rectrcob r, rectrmae t
			 where r.no_tranrec = t.no_tranrec
			   and t.actualizado = 1
			   and t.numrecla = _numrecla
			   and t.cod_tipotran in('004')
			 group by r.cod_cobertura
			 order by r.cod_cobertura
			 
			let _pagos_rec = 0;
			
			select sum(pagos)
			  into _pagos_rec
			  from recrccob
			 where no_reclamo = _no_reclamo
			   and cod_cobertura = _cod_cobertura;
			   
			if abs(_pagos_rec) <> abs(_monto_tr) then
			    if a_valor <> 0 then
					update recrccob
					   set pagos         = _monto_tr
					 where no_reclamo    = _no_reclamo
					   and cod_cobertura = _cod_cobertura;
				end if	   
				select nombre into _n_cob from prdcober where cod_cobertura = _cod_cobertura;
				return 1,_numrecla,_n_cob,_monto_tr,_pagos_rec with resume;
			end if
		end foreach
end foreach
return 0,"","",0,0;
end
end procedure
